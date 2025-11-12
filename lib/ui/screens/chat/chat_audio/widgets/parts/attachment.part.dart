part of "../chat_widget.dart";

class AttachmentMessage extends StatefulWidget {
  final String url;

  const AttachmentMessage({super.key, required this.url});

  @override
  State<AttachmentMessage> createState() => _AttachmentMessageState();
}

class _AttachmentMessageState extends State<AttachmentMessage> {
  late final _url = Uri.tryParse(widget.url);
  late final _fileNameWithExtension = _url?.pathSegments.last;
  late final _extension = _fileNameWithExtension?.split('.').last;
  late final _isImageSupported = ['jpg', 'jpeg', 'png'].contains(_extension);
  late final savePath = '${Constant.savePath}/chat/$_fileNameWithExtension';
  final percentage = ValueNotifier(0.0);

  bool get _isNetworkImage => _url?.host.isNotEmpty ?? false;

  bool get fileExists => File(savePath).existsSync();

  @override
  void dispose() {
    percentage.dispose();
    super.dispose();
  }

  void _downloadFile() async {
    await Api.download(
        url: _url.toString(),
        savePath: savePath,
        onUpdate: (value) => percentage.value = value);

    OpenFilex.open(savePath);
  }

  Widget _fallbackAttachmentWidget() {
    return Row(children: [
      GestureDetector(
        onTap: () {
          if (fileExists) {
            OpenFilex.open(savePath);
          } else {
            _downloadFile();
          }
        },
        child: SizedBox(
          height: 50,
          width: 50,
          child: DecoratedBox(
            decoration: BoxDecoration(
                color: context.color.textLightColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: context.color.borderColor, width: 1.8)),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CustomText(_extension!.toUpperCase()),
              if (!fileExists && _isNetworkImage)
                ValueListenableBuilder(
                    valueListenable: percentage,
                    builder: (context, value, child) {
                      if (value >= .99) return SizedBox.shrink();
                      return Icon(
                        Icons.download,
                        size: 14,
                        color: context.color.territoryColor,
                      );
                    })
            ]),
          ),
        ),
      ),
      Expanded(
        child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: CustomText(
              _fileNameWithExtension!,
              maxLines: 1,
            )),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return _isImageSupported
        ? GestureDetector(
            onTap: () {
              print(savePath);
              if (fileExists) {
                OpenFilex.open(savePath);
              } else if (!_isNetworkImage) {
                OpenFilex.open(_url.toString());
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: _isNetworkImage
                      ? CachedNetworkImage(
                          imageUrl: widget.url,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(widget.url),
                          fit: BoxFit.cover,
                        ),
                ),
                if (!fileExists && _isNetworkImage)
                  ValueListenableBuilder(
                      valueListenable: percentage,
                      builder: (context, value, child) {
                        if (value >= .99) return SizedBox.shrink();
                        return CircleAvatar(
                          backgroundColor: context.color.territoryColor,
                          foregroundColor: Colors.white,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (value == 0.0)
                                IconButton(
                                    onPressed: _downloadFile,
                                    icon: Icon(Icons.download)),
                              if (value != 0.0)
                                CircularProgressIndicator(
                                  value: value,
                                  color: Colors.white,
                                )
                            ],
                          ),
                        );
                      })
              ],
            ),
          )
        : _fallbackAttachmentWidget();
  }
}
