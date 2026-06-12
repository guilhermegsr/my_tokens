// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'MyTokens';

  @override
  String get searchHint => 'Pesquisar contas';

  @override
  String get searchCancel => 'Cancelar';

  @override
  String get hideTokens => 'Ocultar códigos';

  @override
  String get showTokens => 'Mostrar códigos';

  @override
  String accountsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contas encontradas',
      one: '1 conta encontrada',
      zero: 'Nenhuma conta encontrada',
    );
    return '$_temp0';
  }

  @override
  String get emptyTitle => 'Nenhuma conta ainda';

  @override
  String get emptyBody =>
      'Adicione uma conta para começar a gerar códigos de verificação.';

  @override
  String get emptySearch => 'Nenhuma conta corresponde à pesquisa.';

  @override
  String get codeCopied => 'Código copiado para a área de transferência';

  @override
  String get unlockTitle => 'MyTokens está bloqueado';

  @override
  String get unlockReason =>
      'Confirme sua identidade para acessar seus códigos';

  @override
  String get unlockButton => 'Desbloquear';

  @override
  String get removeAccountTitle => 'Remover conta';

  @override
  String removeAccountMessage(String account) {
    return 'Remover \"$account\"? Esta conta não poderá ser recuperada sem um backup.';
  }

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionRemove => 'Remover';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionSave => 'Salvar alterações';

  @override
  String get actionDismiss => 'Dispensar';

  @override
  String get clockWarningTitle => 'O relógio do aparelho pode estar errado';

  @override
  String get clockWarningBody =>
      'O relógio parece ter voltado no tempo. Os códigos de verificação dependem do horário correto e podem não funcionar até que seja ajustado.';

  @override
  String get editAccountTitle => 'Editar conta';

  @override
  String get editAccountSubtitle => 'Atualize como esta conta é identificada';

  @override
  String accountUpdated(String account) {
    return '\"$account\" atualizada';
  }

  @override
  String get drawerTitle => 'MyTokens';

  @override
  String get drawerExport => 'Exportar';

  @override
  String get drawerExportSubtitle =>
      'Salvar uma cópia criptografada das suas contas';

  @override
  String get drawerImport => 'Importar';

  @override
  String get drawerImportSubtitle => 'Restaurar contas de um arquivo de backup';

  @override
  String get drawerSettings => 'Configurações';

  @override
  String get drawerSettingsSubtitle => 'Bloqueio e aparência';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSecurity => 'Segurança';

  @override
  String get settingsAppLock => 'Bloqueio do app';

  @override
  String get settingsAppLockSubtitle =>
      'Exigir biometria ou desbloqueio do aparelho para abrir o MyTokens';

  @override
  String get settingsScreenCapture => 'Capturas e compartilhamento';

  @override
  String get settingsScreenCaptureSubtitle =>
      'Permite prints, gravações e chamadas com tela compartilhada. Use apenas com códigos seguros ou fictícios.';

  @override
  String get settingsCopyOnTap => 'Copiar códigos ao tocar';

  @override
  String get settingsCopyOnTapSubtitle =>
      'Copia OTPs para a área de transferência do sistema. Desative para manter os códigos no MyTokens.';

  @override
  String get settingsAutoLock => 'Bloquear ao sair do app';

  @override
  String get settingsLockImmediately => 'Imediatamente';

  @override
  String get settingsLockAfter30s => 'Após 30 segundos';

  @override
  String get settingsLockAfter1m => 'Após 1 minuto';

  @override
  String get settingsLockAfter5m => 'Após 5 minutos';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String appVersionLabel(String version) {
    return 'MyTokens · v$version';
  }

  @override
  String get addScanTitle => 'Escanear QR Code';

  @override
  String get addScanSubtitle => 'Use o QR Code fornecido pelo serviço';

  @override
  String get addManualTitle => 'Inserir manualmente';

  @override
  String get addManualSubtitle => 'Digite a chave de configuração manualmente';

  @override
  String accountAdded(String account) {
    return '\"$account\" foi adicionada';
  }

  @override
  String get accountDuplicate => 'Esta conta já está no MyTokens.';

  @override
  String get scanInstruction => 'Alinhe o QR Code dentro da área indicada';

  @override
  String get fieldIssuer => 'Serviço';

  @override
  String get fieldIssuerHint => 'Google, GitHub…';

  @override
  String get fieldAccount => 'Conta';

  @override
  String get fieldAccountHint => 'voce@email.com';

  @override
  String get fieldAccountRequired => 'Informe o nome da conta';

  @override
  String get fieldSecret => 'Chave de configuração';

  @override
  String get fieldSecretHint => 'JBSWY3DPEHPK3PXP';

  @override
  String get fieldSecretRequired => 'Informe a chave de configuração';

  @override
  String get fieldSecretInvalid => 'Esta chave de configuração não é válida';

  @override
  String get advancedOptions => 'Opções avançadas';

  @override
  String get fieldDigits => 'Dígitos';

  @override
  String get fieldPeriod => 'Intervalo (s)';

  @override
  String get fieldAlgorithm => 'Algoritmo';

  @override
  String get addAccountButton => 'Adicionar conta';

  @override
  String get backupShareSubject => 'Backup do MyTokens';

  @override
  String get backupNoAccounts => 'Não há contas para fazer backup.';

  @override
  String get backupNotMyTokens =>
      'Este arquivo não é um backup válido do MyTokens.';

  @override
  String get backupWrongPassword => 'Senha incorreta ou o backup foi alterado.';

  @override
  String get backupCorrupted =>
      'O arquivo selecionado é inválido ou está corrompido.';

  @override
  String get backupFailed =>
      'Não foi possível concluir a operação. Tente novamente.';

  @override
  String get backupWorking => 'Processando…';

  @override
  String backupImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contas importadas com sucesso.',
      one: '1 conta importada com sucesso.',
      zero: 'Nenhuma conta nova para importar.',
    );
    return '$_temp0';
  }

  @override
  String get backupPasswordTitle => 'Senha do backup';

  @override
  String get backupPasswordSetHint =>
      'Defina uma senha para proteger este backup. Sem ela, o backup não poderá ser restaurado.';

  @override
  String get backupPasswordEnterHint =>
      'Digite a senha usada quando este backup foi criado.';

  @override
  String get fieldPassword => 'Senha';

  @override
  String get fieldPasswordConfirm => 'Confirmar senha';

  @override
  String get fieldPasswordRequired => 'Digite a senha do backup';

  @override
  String get fieldPasswordTooShort =>
      'Use pelo menos 16 caracteres e evite padrões comuns';

  @override
  String get fieldPasswordMismatch => 'As senhas não coincidem';

  @override
  String get importConflictTitle => 'Algumas contas já existem';

  @override
  String importConflictQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count contas deste backup já estão neste aparelho. Substituir pelas versões do backup ou manter as que você tem?',
      one:
          '1 conta deste backup já está neste aparelho. Substituir pela versão do backup ou manter a que você tem?',
    );
    return '$_temp0';
  }

  @override
  String get importReplaceWithBackup => 'Usar backup';

  @override
  String get importKeepExisting => 'Manter as minhas';
}
