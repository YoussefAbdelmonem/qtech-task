enum RequestState {
  loading,
  loadingAll,
  done,
  error,
  initial;

  bool get isLoading => this == RequestState.loading;

  bool get isLoadingAll => this == RequestState.loadingAll;

  bool get isDone => this == RequestState.done;

  bool get isError => this == RequestState.error;

  bool get isInitial => this == RequestState.initial;
}

enum ErrorType {
  network,
  server,
  backEndValidation,
  emptyData,
  unknown,
  none,
  unAuth
}

enum VerifyType {
  login,
  register,
  forgetPassword,
  editPhone;

  bool get isLogin => this == VerifyType.login;

  bool get isRegister => this == VerifyType.register;
}

enum ThemeType { dark, light }

enum FileType {
  resume,
  personId,
  professionalCertificate;

  bool get isResume => this == FileType.resume;
  bool get isPersonId => this == FileType.personId;
  bool get isProfessionalCertificate =>
      this == FileType.professionalCertificate;
}

extension FileTypeX on FileType {
  String get name {
    switch (this) {
      case FileType.resume:
        return 'Resume';
      case FileType.personId:
        return 'Resume';
      case FileType.professionalCertificate:
        return 'Resume';
    }
  }

  String get url {
    switch (this) {
      case FileType.resume:
        return 'UploadResume';
      case FileType.personId:
        return 'UploadPersonalId';
      case FileType.professionalCertificate:
        return 'UploadProfessionalCertificate';
    }
  }
}

enum ConnectionStatus {
  connecting,
  connected,
  disconnected,
}

enum MessageInputType {
  text,
  image,
  audio,
  file;

  bool get isFile => this == MessageInputType.file;
  bool get isImage => this == MessageInputType.image;
  bool get isAudio => this == MessageInputType.audio;
  bool get isText => this == MessageInputType.text;
}

extension MessageTypeX on MessageInputType {
  int get intValue {
    switch (this) {
      case MessageInputType.text:
        return 1;
      case MessageInputType.image:
        return 2;
      case MessageInputType.audio:
        return 3;
      case MessageInputType.file:
        return 4;
    }
  }

  static MessageInputType fromName(int name) {
    switch (name) {
      case 1:
        return MessageInputType.text;
      case 2:
        return MessageInputType.image;
      case 3:
        return MessageInputType.audio;
      case 4:
        return MessageInputType.file;
      default:
        return MessageInputType.text;
    }
  }
}
