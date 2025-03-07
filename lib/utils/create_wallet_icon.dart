import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';

/// Utility to generate a wallet icon for the README
class WalletIconGenerator {
  /// Generate a wallet icon and save it to the assets directory
  static Future<void> generateWalletIcon() async {
    // Create a wallet icon widget
    final logoWidget = RepaintBoundary(
      child: Container(
        width: 240,
        height: 240,
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 100,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
    
    // Create a simple widget to render
    final RenderRepaintBoundary boundary = RenderRepaintBoundary();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
    final RenderView renderView = RenderView(
      view: RendererBinding.instance.views.first,
      configuration: ViewConfiguration(
        size: const Size(240, 240),
        devicePixelRatio: 1.0,
      ),
      window: PlatformDispatcher.instance.views.first,
    );

    final RenderObjectToWidgetAdapter<RenderBox> adapter = RenderObjectToWidgetAdapter<RenderBox>(
      container: boundary,
      child: logoWidget,
    );

    // Attach the adapter to the render object
    boundary.child = adapter.attachToRenderTree(buildOwner);
    
    // Ensure layout is complete
    renderView.prepareInitialFrame();
    boundary.layout(const BoxConstraints(maxWidth: 240, maxHeight: 240));
    buildOwner.buildScope(adapter.rootElement!);
    buildOwner.finalizeTree();
    
    // Render the image
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData != null) {
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      
      // Save to file
      final file = File('assets/images/wallet_icon.png');
      await file.writeAsBytes(pngBytes);
      
      print('Wallet icon generated and saved to ${file.path}');
    } else {
      print('Failed to generate wallet icon');
    }
  }
} 