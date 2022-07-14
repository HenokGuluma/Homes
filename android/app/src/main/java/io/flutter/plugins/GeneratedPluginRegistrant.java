package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import com.lazyarts.vikram.cached_video_player.CachedVideoPlayerPlugin;
import io.flutter.plugins.camera.CameraPlugin;
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin;
import com.mr.flutter.plugin.filepicker.FilePickerPlugin;
import io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin;
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin;
import io.flutter.plugins.firebase.storage.FirebaseStoragePlugin;
import com.arthenica.flutter.ffmpeg.FlutterFFmpegPlugin;
import com.example.flutterimagecompress.FlutterImageCompressPlugin;
import io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin;
import com.example.flutter_video_compress.FlutterVideoCompressPlugin;
import com.example.flutter_video_info.FlutterVideoInfoPlugin;
import io.github.ponnamkarthik.toast.fluttertoast.FlutterToastPlugin;
import io.github.zeshuaro.google_api_headers.GoogleApiHeadersPlugin;
import io.flutter.plugins.googlesignin.GoogleSignInPlugin;
import com.lykhonis.imagecrop.ImageCropPlugin;
import adhoc.successive.com.fluttergallaryplugin.FlutterGallaryPlugin;
import io.flutter.plugins.imagepicker.ImagePickerPlugin;
import com.example.media_gallery.MediaGalleryPlugin;
import io.flutter.plugins.packageinfo.PackageInfoPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import com.baseflow.permissionhandler.PermissionHandlerPlugin;
import top.kikt.imagescanner.ImageScannerPlugin;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;
import com.tekartik.sqflite.SqflitePlugin;
import com.follow2vivek.storagepath.StoragePathPlugin;
import com.example.video_compress.VideoCompressPlugin;
import io.flutter.plugins.videoplayer.VideoPlayerPlugin;
import xyz.justsoft.video_thumbnail.VideoThumbnailPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    CachedVideoPlayerPlugin.registerWith(registry.registrarFor("com.lazyarts.vikram.cached_video_player.CachedVideoPlayerPlugin"));
    CameraPlugin.registerWith(registry.registrarFor("io.flutter.plugins.camera.CameraPlugin"));
    FlutterFirebaseFirestorePlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin"));
    FilePickerPlugin.registerWith(registry.registrarFor("com.mr.flutter.plugin.filepicker.FilePickerPlugin"));
    FlutterFirebaseAuthPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin"));
    FlutterFirebaseCorePlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin"));
    FirebaseStoragePlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebase.storage.FirebaseStoragePlugin"));
    FlutterFFmpegPlugin.registerWith(registry.registrarFor("com.arthenica.flutter.ffmpeg.FlutterFFmpegPlugin"));
    FlutterImageCompressPlugin.registerWith(registry.registrarFor("com.example.flutterimagecompress.FlutterImageCompressPlugin"));
    FlutterAndroidLifecyclePlugin.registerWith(registry.registrarFor("io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin"));
    FlutterVideoCompressPlugin.registerWith(registry.registrarFor("com.example.flutter_video_compress.FlutterVideoCompressPlugin"));
    FlutterVideoInfoPlugin.registerWith(registry.registrarFor("com.example.flutter_video_info.FlutterVideoInfoPlugin"));
    FlutterToastPlugin.registerWith(registry.registrarFor("io.github.ponnamkarthik.toast.fluttertoast.FlutterToastPlugin"));
    GoogleApiHeadersPlugin.registerWith(registry.registrarFor("io.github.zeshuaro.google_api_headers.GoogleApiHeadersPlugin"));
    GoogleSignInPlugin.registerWith(registry.registrarFor("io.flutter.plugins.googlesignin.GoogleSignInPlugin"));
    ImageCropPlugin.registerWith(registry.registrarFor("com.lykhonis.imagecrop.ImageCropPlugin"));
    FlutterGallaryPlugin.registerWith(registry.registrarFor("adhoc.successive.com.fluttergallaryplugin.FlutterGallaryPlugin"));
    ImagePickerPlugin.registerWith(registry.registrarFor("io.flutter.plugins.imagepicker.ImagePickerPlugin"));
    MediaGalleryPlugin.registerWith(registry.registrarFor("com.example.media_gallery.MediaGalleryPlugin"));
    PackageInfoPlugin.registerWith(registry.registrarFor("io.flutter.plugins.packageinfo.PackageInfoPlugin"));
    PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    PermissionHandlerPlugin.registerWith(registry.registrarFor("com.baseflow.permissionhandler.PermissionHandlerPlugin"));
    ImageScannerPlugin.registerWith(registry.registrarFor("top.kikt.imagescanner.ImageScannerPlugin"));
    SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
    SqflitePlugin.registerWith(registry.registrarFor("com.tekartik.sqflite.SqflitePlugin"));
    StoragePathPlugin.registerWith(registry.registrarFor("com.follow2vivek.storagepath.StoragePathPlugin"));
    VideoCompressPlugin.registerWith(registry.registrarFor("com.example.video_compress.VideoCompressPlugin"));
    VideoPlayerPlugin.registerWith(registry.registrarFor("io.flutter.plugins.videoplayer.VideoPlayerPlugin"));
    VideoThumbnailPlugin.registerWith(registry.registrarFor("xyz.justsoft.video_thumbnail.VideoThumbnailPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
