import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg;
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qtech_task/core/extensions/extensions.dart';

import 'base_shimmer.dart';

enum ImageType { network, networkSvg, assetSvg, lottie, file, asset, error }

class CustomImage extends StatelessWidget {
  final double? height, width;
  final String? url;
  final bool isFile;
  final BoxFit fit;
  final BoxBorder? border;
  final Widget? child;
  final Function? onFinishLottie;

  final Color? blurColor, color, backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final bool matchDirection;

  const CustomImage(
    this.url, {
    super.key,
    this.height,
    this.width,
    this.isFile = false,
    this.borderRadius,
    BoxFit? fit,
    this.color,
    this.backgroundColor,
    this.border,
    this.child,
    bool? matchDirection,
    this.blurColor,
    this.onFinishLottie,
  }) : fit = fit ?? BoxFit.contain,
       matchDirection = matchDirection ?? false;

  ImageType _getImageType() {
    if (url?.isEmpty ?? true) return ImageType.error;

    final extension = url?.split('.').last.toLowerCase() ?? '';
    final isHttp = url?.startsWith('http') ?? false;

    if (isHttp && extension != 'svg') return ImageType.network;
    if (isHttp && extension == 'svg') return ImageType.networkSvg;
    if (extension == 'svg') return ImageType.assetSvg;
    if (extension == 'json') return ImageType.lottie;
    if (isFile) return ImageType.file;
    return ImageType.asset;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      // margin: EdgeInsets.all(s),
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.zero,
        color: backgroundColor,
        border: border,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            _buildImage(context).center,
            if (blurColor != null)
              Container(
                height: height,
                width: width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: borderRadius ?? BorderRadius.zero,
                  color: blurColor,
                ),
              ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    switch (_getImageType()) {
      case ImageType.network:
        return CacheNetworkImage(
          url!,
          height: height,
          width: width,
          fit: fit,
          color: color,
          borderRadius: borderRadius,
        );
      case ImageType.networkSvg:
        return SvgPicture.network(
          url!,
          height: height,
          width: width,
          fit: fit,
          placeholderBuilder: (context) =>
              Icon(Icons.broken_image, color: context.hoverColor),
        );
      case ImageType.assetSvg:
        return SvgPicture.asset(
          url!,
          height: height,
          matchTextDirection: matchDirection,
          width: width,
          fit: fit,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
        );
      case ImageType.lottie:
        return CustomLottie(
          url!,
          height: height,
          width: width,
          fit: fit,
          onFinish: onFinishLottie,
        );
      case ImageType.file:
        return Image.file(
          File(url!),
          height: height,
          width: width,
          fit: fit,
          color: color,
          errorBuilder: (context, error, stackTrace) => _errorWidget(context),
        );
      case ImageType.asset:
        return Image.asset(
          url!,
          width: width,
          height: height,
          fit: fit,
          color: color,
          errorBuilder: (context, error, stackTrace) => _errorWidget(context),
        );
      case ImageType.error:
        return _errorWidget(context);
    }
  }

  Widget _errorWidget(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: borderRadius,
      border: border ?? Border.all(color: context.hoverColor),
    ),
    height: height,
    width: width,
    child: FittedBox(
      fit: BoxFit.fill,
      child: Icon(
        Icons.broken_image_outlined,
        color: context.hoverColor,
        size: 30,
      ),
    ),
  );
}

class CustomIconImage extends StatelessWidget {
  final String url;
  final double? size;
  final Color? color;

  const CustomIconImage(this.url, {super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return ImageIcon(getImage(), size: size, color: color);
  }

  getImage() {
    if (url.split(".").last == "svg") {
      return svg.Svg(url);
    } else {
      return AssetImage(url);
    }
  }
}

class CustomLottie extends StatefulWidget {
  final double? height, width;
  final String? url;
  final BoxFit? fit;
  final Function? onFinish;

  const CustomLottie(
    this.url, {
    super.key,
    this.height,
    this.width,
    this.fit,
    this.onFinish,
  });

  @override
  State<CustomLottie> createState() => _CustomLottieState();
}

class _CustomLottieState extends State<CustomLottie>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.url!,
      height: widget.height,
      width: widget.width,
      fit: widget.fit ?? BoxFit.contain,
      repeat: false,
      onLoaded: (composition) {
        _controller
          ..duration = composition.duration
          ..forward().whenComplete(
            () => Timer(1.seconds, () {
              if (widget.onFinish != null) widget.onFinish!();
            }),
          );
      },
    );
  }
}

class CacheNetworkImage extends StatefulWidget {
  final String url;
  final double? height, width;
  final BoxBorder? border;
  final BoxFit fit;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;

  const CacheNetworkImage(
    this.url, {
    super.key,
    this.height,
    this.width,
    BoxFit? fit,
    this.color,
    this.borderRadius,
    this.border,
  }) : fit = fit ?? BoxFit.contain;

  @override
  State<CacheNetworkImage> createState() => _CacheNetworkImageState();
}

class _CacheNetworkImageState extends State<CacheNetworkImage> {
  final _dio = Dio();
  Directory? _cacheDirectory;
  bool _isLoading = true;
  String? _path;
  static const int _maxCacheAge = 7; // Days to keep cache

  Future<String?> _downloadImage(String url) async {
    try {
      _isLoading = true;
      if (mounted) setState(() {});

      _cacheDirectory ??= await getApplicationCacheDirectory();
      final fileName = md5.convert(utf8.encode(url)).toString();
      final savePath = '${_cacheDirectory!.path}/$fileName';

      final file = File(savePath);
      if (await file.exists()) {
        final fileStats = await file.stat();
        final age = DateTime.now().difference(fileStats.modified).inDays;

        if (age > _maxCacheAge) {
          await file.delete();
        } else {
          return _path = savePath;
        }
      }

      await _dio.download(url, savePath);
      return _path = savePath;
    } catch (e) {
      return null;
    } finally {
      _isLoading = false;
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _downloadImage(widget.url);
    _cleanupOldCache();
  }

  Future<void> _cleanupOldCache() async {
    try {
      _cacheDirectory ??= await getApplicationCacheDirectory();
      final dir = Directory(_cacheDirectory!.path);
      await for (final file in dir.list()) {
        if (file is File) {
          final stats = await file.stat();
          final age = DateTime.now().difference(stats.modified).inDays;
          if (age > _maxCacheAge) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      // Handle cleanup errors silently
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_path != null) {
      return Image.file(
        File(_path!),
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        color: widget.color,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else if (_isLoading) {
      return _buildLoadingWidget();
    } else {
      return _buildErrorWidget();
    }
  }

  Widget _buildLoadingWidget() => Container(
    width: widget.width,
    height: widget.height,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
    ),
    child: BaseShimmer(
      child: Center(
        child: CustomImage(
          "Assets.svg.logo",
          height: 20,
        ).paddingAll(horizontal: 10),
      ),
    ),
  );

  Widget _buildErrorWidget() => Container(
    margin: EdgeInsets.all(3),
    decoration: BoxDecoration(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
      border: widget.border ?? Border.all(color: Colors.grey.shade200),
    ),
    height: widget.height,
    width: widget.width,
    child: Container(
      constraints: BoxConstraints(maxWidth: 30, maxHeight: 30),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.fill,
        child: Icon(Icons.broken_image, color: Colors.grey.shade200),
      ),
    ),
  );

  @override
  void dispose() {
    super.dispose();
  }
}

extension CacheNetworkImageExtension on CacheNetworkImage {
  Future<ImageProvider?> getImageProvider() async {
    final dio = Dio();
    Directory? cacheDirectory;
    String? path;

    try {
      cacheDirectory ??= await getApplicationCacheDirectory();
      final savePath = '${cacheDirectory.path}/${url.split('/').last}';
      final isDownloaded = await File(savePath).exists();
      if (isDownloaded) {
        path = savePath;
      } else {
        await dio.download(url, savePath);
        path = savePath;
      }
      return FileImage(File(path));
    } catch (e) {
      return null;
    }
  }
}

class IconWrapper extends StatelessWidget {
  final Widget child;
  const IconWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Color(0xffE9ECEE)),
      ),
      child: child,
    );
  }
}
