import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageService {
  static const String defaultImageUrl = 'https://via.placeholder.com/150';
  static const Duration cacheMaxAge = Duration(days: 7);

  // Cache configuration
  static final Map<String, CachedNetworkImageProvider> _imageCache = {};

  // Get cached image provider - reuse existing providers to reduce memory usage
  static CachedNetworkImageProvider getImageProvider(String? url) {
    final imageUrl = url?.isNotEmpty == true ? url! : defaultImageUrl;

    if (!_imageCache.containsKey(imageUrl)) {
      _imageCache[imageUrl] = CachedNetworkImageProvider(
        imageUrl,
        maxHeight: 300, // Limit max height for memory optimization
        maxWidth: 300, // Limit max width for memory optimization
      );
    }

    return _imageCache[imageUrl]!;
  }

  // Helper method to safely convert double to int for cache
  static int? _safeToInt(double? value) {
    if (value == null || value.isInfinite || value.isNaN) {
      return null;
    }
    return value.toInt();
  }

  // Optimized network image with caching, placeholder and error handling
  static Widget optimizedNetworkImage({
    required String? url,
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    BorderRadius? borderRadius,
    Color? placeholderColor,
  }) {
    final imageUrl = url?.isNotEmpty == true ? url! : defaultImageUrl;

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: fit,
      maxHeightDiskCache: 300, // Optimize disk cache size
      maxWidthDiskCache: 300, // Optimize disk cache size
      // Safely convert height and width to int, avoiding infinity
      memCacheHeight: _safeToInt(height),
      memCacheWidth: _safeToInt(width),
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder:
          (context, url) =>
              placeholder ??
              Container(
                color: placeholderColor ?? Colors.grey.shade300,
                child: Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
      errorWidget:
          (context, url, error) =>
              errorWidget ??
              Container(
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.white),
                ),
              ),
    );

    // Apply border radius if provided
    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius, child: image);
    }

    return image;
  }

  // Avatar image with caching and error handling
  static Widget avatarImage({
    required String? url,
    required double radius,
    Color? backgroundColor,
  }) {
    final imageUrl = url?.isNotEmpty == true ? url! : defaultImageUrl;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder:
          (context, imageProvider) => CircleAvatar(
            radius: radius,
            backgroundImage: imageProvider,
            backgroundColor: backgroundColor ?? Colors.grey.shade200,
          ),
      placeholder:
          (context, url) => CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor ?? Colors.grey.shade200,
            child: SizedBox(
              height: radius * 0.6,
              width: radius * 0.6,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
              ),
            ),
          ),
      errorWidget:
          (context, url, error) => CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor ?? Colors.grey.shade200,
            child: Icon(
              Icons.person,
              size: radius * 0.8,
              color: Colors.grey.shade600,
            ),
          ),
    );
  }

  // Clear the image cache
  static void clearCache() {
    _imageCache.clear();
    PaintingBinding.instance.imageCache.clear();
    CachedNetworkImage.evictFromCache(defaultImageUrl);
  }
}
