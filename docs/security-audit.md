# Relatorio de Auditoria de Seguranca

Data: 2026-06-12  
Projeto: MyTokens  
Escopo: aplicacao Flutter/Dart Android, criptografia local, TOTP, backup/importacao, app lock, clipboard, Android manifest, Gradle, CI/CD, dependencias e documentacao.

## Resumo Executivo

Security Score final: **76/100**

O projeto tem boas bases de seguranca: nao possui backend, nao declara permissao `INTERNET` no manifest de release, usa cofre local com AES-256-GCM, `flutter_secure_storage`, bloqueio de backup Android, `FLAG_SECURE` por padrao e testes para TOTP/backup. Os principais riscos encontrados sao locais: DoS persistente por entrada TOTP nao validada em QR/importacao, bypass de auto-lock durante UI do sistema, fallback inseguro para debug signing em release, exportacao de seeds sem reautenticacao e exposicao de OTP no clipboard.

## Validacoes Realizadas

- `flutter analyze`: sem issues.
- `flutter test`: todos os testes passaram.
- `dart pub outdated --json`: nenhuma dependencia atual marcada como afetada por advisory pelo Pub.
- Busca regex por segredos: nao foram encontrados tokens cloud, JWTs, chaves privadas ou credenciais reais.
- Ferramentas indisponiveis no ambiente: `gitleaks`, `osv-scanner`, `trivy`.

## Tabela Resumo

| ID | Tipo | Severidade | Confianca | Vulnerabilidade | Prioridade |
|---|---|---|---|---|---|
| SEC-01 | Confirmada | Alta | Alto | DoS persistente por segredo TOTP invalido em QR/importacao | Imediata |
| SEC-02 | Confirmada | Media | Alto | Bypass de auto-lock durante share sheet/file picker | Imediata |
| SEC-03 | Confirmada | Media | Alto | Importacao de backup sem limite de tamanho | Alta |
| SEC-04 | Provavel | Alta | Alto | Release pode ser assinado com debug key | Imediata |
| SEC-05 | Provavel | Media | Medio | Configuracoes sensiveis sem reautenticacao | Imediata |
| SEC-06 | Provavel | Media | Medio | Exportacao de seeds sem step-up auth e arquivo temporario residual | Imediata |
| SEC-07 | Confirmada | Media | Alto | OTP exposto no clipboard global | Alta |
| SEC-08 | Possivel risco | Media | Medio | Politica de senha de backup baseada apenas em tamanho | Media |
| SEC-09 | Possivel risco | Baixa | Medio | Race condition em saves do cofre | Media |
| SEC-10 | Possivel risco | Baixa | Medio | Hardening insuficiente de CI/supply chain | Media |

## Top 10 Riscos Por Prioridade

1. Validar segredo TOTP em QR/import antes de salvar.
2. Remover fallback de debug signing em release.
3. Corrigir reavaliacao de auto-lock apos share sheet/file picker.
4. Exigir reautenticacao para exportar backup.
5. Exigir reautenticacao para desativar app lock ou permitir captura de tela.
6. Limitar tamanho e estrutura de arquivos `.mytokens`.
7. Apagar backup temporario apos compartilhamento.
8. Reduzir exposicao no clipboard e marcar conteudo como sensivel.
9. Fortalecer politica de senha de backup.
10. Endurecer CI/supply chain com pinning, permissoes minimas e checksums.

## SEC-01: DoS Persistente Por Segredo TOTP Invalido

### Severidade

Alta

### Tipo

Vulnerabilidade confirmada

### Arquivos Afetados

- `lib/data/otpauth_uri.dart:18-21`
- `lib/data/otpauth_uri.dart:47-52`
- `lib/data/account.dart:16-30`
- `lib/ui/add_account/scan_page.dart:68-75`
- `lib/ui/backup/backup_flow.dart:127-130`
- `lib/ui/home_page.dart:217`
- `lib/core/totp/totp_generator.dart:132-146`

### Trecho Relevante

```dart
final secret = parsed.queryParameters['secret'];
if (secret == null || secret.isEmpty) {
  throw const FormatException('Missing "secret" parameter.');
}

return Account(
  id: id,
  issuer: issuer,
  label: label,
  secret: secret,
  digits: digits,
  period: period,
);
```

### Explicacao Tecnica

O fluxo de QR/importacao aceita qualquer `secret` nao vazio. A validacao real de base32 so ocorre posteriormente, quando a tela inicial chama `store.codeFor(account)` e o `TotpGenerator` tenta decodificar o segredo. Um segredo invalido persistido passa a quebrar a renderizacao da lista em todo carregamento.

### Cenario de Exploracao

Um atacante convence a vitima a escanear um QR como `otpauth://totp/A?secret=!!!!` ou importar backup contendo um segredo invalido. A conta e salva e o app passa a falhar ao calcular o TOTP.

### Impacto

Indisponibilidade persistente do autenticador ate que a conta maliciosa seja removida ou o cofre seja reparado externamente.

### Nivel de Confianca

Alto

### Correcao Recomendada

Validar, normalizar e limitar o tamanho do segredo TOTP antes de persistir dados vindos de QR ou backup.

### Exemplo Corrigido

```dart
static String validateSecret(String secret) {
  final normalized = secret.replaceAll(RegExp(r'[\s=]'), '').toUpperCase();

  if (normalized.isEmpty || normalized.length > 256) {
    throw const FormatException('Invalid secret length.');
  }

  if (!RegExp(r'^[A-Z2-7]+$').hasMatch(normalized)) {
    throw const FormatException('Invalid base32 secret.');
  }

  const TotpGenerator().generate(normalized);
  return normalized;
}
```

### Referencias

- OWASP MASVS-INPUT
- CWE-20: Improper Input Validation
- CWE-400: Uncontrolled Resource Consumption

## SEC-02: Bypass De Auto-Lock Durante Share/File Picker

### Severidade

Media

### Tipo

Vulnerabilidade confirmada

### Arquivos Afetados

- `lib/ui/security/biometric_gate.dart:29-35`
- `lib/ui/security/biometric_gate.dart:70-73`
- `lib/ui/backup/backup_flow.dart:79-84`
- `lib/ui/backup/backup_flow.dart:93-95`

### Trecho Relevante

```dart
static Future<T> withoutAutoLock<T>(Future<T> Function() action) async {
  _systemInteractionDepth++;
  try {
    return await action();
  } finally {
    _systemInteractionDepth--;
  }
}

if (BiometricGate._autoLockSuspended) return;
```

### Explicacao Tecnica

Enquanto a share sheet ou file picker esta aberta, eventos de ciclo de vida sao ignorados. Ao retornar para o app, o timeout de bloqueio nao e reavaliado.

### Cenario de Exploracao

O usuario abre exportacao/importacao, o app vai para background via UI do sistema e retorna depois do timeout configurado. Mesmo com lock imediato, a tela pode continuar desbloqueada.

### Impacto

Codigos TOTP podem permanecer visiveis sem nova autenticacao.

### Nivel de Confianca

Alto

### Correcao Recomendada

Suprimir apenas o relock destrutivo durante a UI do sistema, mas registrar o horario de background e reavaliar o timeout ao retornar.

### Exemplo Corrigido

```dart
if (BiometricGate._autoLockSuspended) {
  if (state == AppLifecycleState.paused) {
    _backgroundedAt = DateTime.now();
    context.read<SettingsStore>().recordBackgrounded();
  }

  if (state == AppLifecycleState.resumed && _backgroundedAt != null) {
    final away = DateTime.now().difference(_backgroundedAt!);
    _backgroundedAt = null;
    if (away >= context.read<SettingsStore>().lockTimeout.duration) {
      setState(() => _status = _GateStatus.locked);
      _authenticate();
    }
  }
  return;
}
```

### Referencias

- OWASP MASVS-AUTH
- CWE-287: Improper Authentication
- CWE-613: Insufficient Session Expiration

## SEC-03: Importacao De Backup Sem Limite De Tamanho

### Severidade

Media

### Tipo

Vulnerabilidade confirmada

### Arquivos Afetados

- `lib/ui/backup/backup_flow.dart:93-104`
- `lib/ui/backup/backup_flow.dart:122-130`

### Trecho Relevante

```dart
final picked = await BiometricGate.withoutAutoLock(
  () => FilePicker.platform.pickFiles(withData: true),
);

final bytes = file.bytes ?? await File(file.path!).readAsBytes();
header = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
```

### Explicacao Tecnica

O arquivo selecionado e carregado inteiro em memoria com `withData: true`. Nao ha limite de tamanho do arquivo, tamanho de campos, tamanho do payload ou quantidade de contas.

### Cenario de Exploracao

Um arquivo `.mytokens` muito grande ou especialmente construido e selecionado pelo usuario. O app consome memoria/CPU durante leitura, UTF-8 decode, JSON parse e decriptacao/processamento.

### Impacto

Crash, travamento ou negação de servico local.

### Nivel de Confianca

Alto

### Correcao Recomendada

Usar `withData: false`, checar tamanho com `File.length()` antes da leitura e impor limites de estrutura depois da decriptacao.

### Exemplo Corrigido

```dart
final picked = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['mytokens'],
  withData: false,
);

final path = picked?.files.single.path;
if (path == null) return;

final file = File(path);
if (await file.length() > 1024 * 1024) {
  throw const FormatException('Backup too large.');
}

final bytes = await file.readAsBytes();
```

### Referencias

- OWASP MASVS-RESILIENCE
- CWE-400: Uncontrolled Resource Consumption

## SEC-04: Release Pode Ser Assinado Com Debug Key

### Severidade

Alta

### Tipo

Vulnerabilidade provavel / configuracao insegura

### Arquivos Afetados

- `android/app/build.gradle.kts:54-60`
- `RELEASE.md:8-9`

### Trecho Relevante

```kotlin
release {
    signingConfig = if (hasReleaseKeystore) {
        signingConfigs.getByName("release")
    } else {
        signingConfigs.getByName("debug")
    }
}
```

### Explicacao Tecnica

Se `android/key.properties` nao existir, o build `release` usa a chave debug. Isso permite publicar acidentalmente um APK de release com assinatura inadequada.

### Cenario de Exploracao

Um maintainer ou CI gera `flutter build apk --release` sem keystore de release e publica o artefato resultante.

### Impacto

Perda de integridade da distribuicao, update path inconsistente e risco de supply chain.

### Nivel de Confianca

Alto

### Correcao Recomendada

Release deve falhar fechado quando a keystore nao existir.

### Exemplo Corrigido

```kotlin
release {
    check(hasReleaseKeystore) {
        "Release keystore missing. Configure android/key.properties."
    }
    signingConfig = signingConfigs.getByName("release")
}
```

### Referencias

- OWASP MASVS-CODE
- OWASP A08: Software and Data Integrity Failures
- CWE-347: Improper Verification of Cryptographic Signature

## SEC-05: Configuracoes Sensiveis Sem Reautenticacao

### Severidade

Media

### Tipo

Vulnerabilidade provavel

### Arquivos Afetados

- `lib/ui/settings/settings_page.dart:26-39`
- `lib/ui/settings/settings_store.dart:124-143`

### Trecho Relevante

```dart
_SwitchRow(
  title: l10n.settingsAppLock,
  value: settings.lockEnabled,
  onChanged: settings.setLockEnabled,
),
_SwitchRow(
  title: l10n.settingsScreenCapture,
  value: settings.screenCaptureAllowed,
  onChanged: settings.setScreenCaptureAllowed,
),
```

### Explicacao Tecnica

Desativar app lock e permitir captura de tela sao acoes que reduzem o nivel de seguranca. O app permite essas mudancas sem nova autenticacao do sistema.

### Cenario de Exploracao

Um atacante com acesso momentaneo ao app desbloqueado abre settings, desativa o app lock e habilita screen capture.

### Impacto

Enfraquecimento persistente dos controles de protecao local.

### Nivel de Confianca

Medio

### Correcao Recomendada

Exigir step-up authentication antes de qualquer alteracao que reduza seguranca.

### Exemplo Corrigido

```dart
Future<void> changeLockEnabled(BuildContext context, bool value) async {
  if (!value && !await requireDeviceAuth(context)) return;
  await context.read<SettingsStore>().setLockEnabled(value);
}
```

### Referencias

- OWASP MASVS-AUTH
- CWE-287: Improper Authentication
- CWE-306: Missing Authentication for Critical Function

## SEC-06: Exportacao De Seeds Sem Step-Up Auth E Arquivo Temporario Residual

### Severidade

Media

### Tipo

Vulnerabilidade provavel

### Arquivos Afetados

- `lib/ui/backup/backup_flow.dart:46-64`
- `lib/ui/backup/backup_flow.dart:79-84`

### Trecho Relevante

```dart
final password = await _promptPassword(context, isNewPassword: true);

final accountsJson =
    jsonEncode(store.accounts.map((a) => a.toJson()).toList());

await Share.shareXFiles([XFile(filePath)]);
```

### Explicacao Tecnica

Exportar backup libera todos os seeds TOTP. A operacao depende apenas do app ja estar desbloqueado e de uma senha escolhida no momento. O arquivo temporario `mytokens-backup.mytokens` tambem nao e removido explicitamente apos o compartilhamento.

### Cenario de Exploracao

Um atacante com acesso momentaneo ao app desbloqueado exporta todos os segredos para um backup com senha escolhida por ele.

### Impacto

Comprometimento total das contas TOTP cadastradas.

### Nivel de Confianca

Medio

### Correcao Recomendada

Exigir reautenticacao imediatamente antes da exportacao e apagar o arquivo temporario no `finally`.

### Exemplo Corrigido

```dart
if (!await requireDeviceAuth(context)) return;

String? filePath;
try {
  filePath = await createEncryptedBackup();
  await Share.shareXFiles([XFile(filePath)]);
} finally {
  if (filePath != null) {
    await File(filePath).delete().catchError((_) {});
  }
}
```

### Referencias

- OWASP MASVS-AUTH
- OWASP MASVS-STORAGE
- CWE-522: Insufficiently Protected Credentials
- CWE-922: Insecure Storage of Sensitive Information

## SEC-07: OTP Exposto No Clipboard Global

### Severidade

Media

### Tipo

Vulnerabilidade confirmada

### Arquivos Afetados

- `lib/ui/widgets/token_tile.dart:70-84`

### Trecho Relevante

```dart
await Clipboard.setData(ClipboardData(text: value));
_scheduleClipboardClear(value);
```

### Explicacao Tecnica

O TOTP e copiado para o clipboard global por ate 30 segundos. Teclados, clipboard managers ou outros componentes com acesso ao clipboard podem capturar o codigo ainda valido.

### Cenario de Exploracao

O usuario copia um OTP enquanto um teclado ou clipboard manager malicioso monitora o clipboard.

### Impacto

Roubo de OTP valido dentro da janela de tempo.

### Nivel de Confianca

Alto

### Correcao Recomendada

Reduzir o tempo de permanencia, marcar clipboard como sensivel em Android compativel via platform channel e permitir desabilitar copy-on-tap.

### Exemplo Corrigido

```dart
const _clipboardClearDelay = Duration(seconds: 10);

await Clipboard.setData(ClipboardData(text: value));
_scheduleClipboardClear(value);
```

### Referencias

- OWASP MASVS-PRIVACY
- CWE-200: Exposure of Sensitive Information
- CWE-359: Exposure of Private Personal Information

## SEC-08: Senha De Backup Com Validacao Fraca

### Severidade

Media

### Tipo

Possivel risco

### Arquivos Afetados

- `lib/ui/backup/backup_flow.dart:248-257`
- `lib/core/crypto/cipher.dart:49-53`

### Trecho Relevante

```dart
return value.length < 12
    ? l10n.fieldPasswordTooShort
    : null;
```

### Explicacao Tecnica

O backup e protegido por senha e pode ser atacado offline se for obtido por terceiros. Argon2id reduz a viabilidade do ataque, mas aceitar qualquer senha de 12 caracteres ainda permite senhas previsiveis.

### Cenario de Exploracao

Um backup salvo em nuvem, chat ou e-mail e roubado e atacado com wordlists.

### Impacto

Recuperacao dos seeds TOTP caso a senha seja fraca.

### Nivel de Confianca

Medio

### Correcao Recomendada

Usar medidor de forca, exigir passphrase mais robusta e bloquear padroes comuns.

### Exemplo Corrigido

```dart
if (value.length < 16 || RegExp(r'^(.)\1+$').hasMatch(value)) {
  return l10n.fieldPasswordTooShort;
}
```

### Referencias

- OWASP MASVS-CRYPTO
- OWASP Authentication Cheat Sheet
- CWE-521: Weak Password Requirements

## SEC-09: Race Condition Em Saves Do Cofre

### Severidade

Baixa

### Tipo

Possivel risco

### Arquivos Afetados

- `lib/ui/account_store.dart:64-90`
- `lib/data/account_repository.dart:39-47`

### Trecho Relevante

```dart
_accounts = [..._accounts, account];
notifyListeners();
await _repository.save(_accounts);
```

### Explicacao Tecnica

Mutacoes assincronas nao sao serializadas. Dois saves concorrentes podem gravar estados fora de ordem. O repositório tambem usa sempre o mesmo arquivo temporario `${file.path}.tmp`.

### Cenario de Exploracao

Operacoes rapidas de add/remove/import podem fazer um estado antigo sobrescrever um novo.

### Impacto

Conta removida pode reaparecer ou alteracao pode ser perdida.

### Nivel de Confianca

Medio

### Correcao Recomendada

Serializar gravacoes e usar arquivo temporario unico por save.

### Exemplo Corrigido

```dart
Future<void> _saveQueue = Future.value();

Future<void> saveAccounts(List<Account> accounts) {
  final snapshot = List<Account>.from(accounts);
  _saveQueue = _saveQueue.then((_) => _repository.save(snapshot));
  return _saveQueue;
}
```

### Referencias

- CWE-362: Race Condition
- CWE-367: Time-of-check Time-of-use Race Condition

## SEC-10: Hardening Insuficiente De CI/Supply Chain

### Severidade

Baixa

### Tipo

Possivel risco

### Arquivos Afetados

- `.github/workflows/ci.yml:12-16`
- `android/gradle/wrapper/gradle-wrapper.properties:5`
- `android/.gitignore:1-7`
- `pubspec.yaml:15`

### Trecho Relevante

```yaml
- uses: actions/checkout@v4
- uses: subosito/flutter-action@v2
```

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14-all.zip
```

### Explicacao Tecnica

Actions usam tags mutaveis, nao ha `permissions: contents: read`, o Gradle wrapper nao declara `distributionSha256Sum`, e `intl: any` reduz previsibilidade de resolucao futura.

### Cenario de Exploracao

Comprometimento de tag de action, download de distribuicao Gradle sem checksum fixado ou alteracao inesperada de dependencia futura.

### Impacto

Risco de supply chain no build.

### Nivel de Confianca

Medio

### Correcao Recomendada

Pin de actions por SHA, permissoes minimas, checksum da distribuicao Gradle e SCA no CI.

### Exemplo Corrigido

```yaml
permissions:
  contents: read

steps:
  - uses: actions/checkout@<commit-sha>
  - uses: subosito/flutter-action@<commit-sha>
```

### Referencias

- OWASP A08: Software and Data Integrity Failures
- SLSA Supply Chain Security
- CWE-494: Download of Code Without Integrity Check
- CWE-829: Inclusion of Functionality from Untrusted Control Sphere

## Falsos Positivos E Itens Nao Aplicaveis

- SQL/NoSQL/LDAP/SSTI/XXE: nao ha backend, banco SQL, template server-side ou XML parser de entrada.
- SSRF/Open Redirect/CSRF: nao aplicavel ao app release; nao ha chamadas HTTP proprias e nao ha permissao `INTERNET` no manifest principal.
- XSS: entradas de usuario sao renderizadas com widgets `Text`, sem WebView/HTML.
- `android:exported="true"`: esperado para launcher activity com intent-filter `MAIN/LAUNCHER`, sem deep links.
- `INTERNET` em debug/profile: presente apenas em manifests de desenvolvimento.
- `Random()` em account ID: usado apenas como identificador local, nao como segredo.
- Segredos expostos: nao foram encontrados tokens, chaves privadas, JWTs ou credenciais reais no repositorio revisado.

## Correcoes Imediatas

- SEC-01: validar segredo TOTP em QR/import antes de persistir.
- SEC-02: reavaliar auto-lock no retorno de share sheet/file picker.
- SEC-04: falhar build release se keystore de release nao existir.
- SEC-05: exigir reautenticacao para reduzir controles de seguranca.
- SEC-06: exigir reautenticacao para exportar backup e apagar arquivo temporario.
