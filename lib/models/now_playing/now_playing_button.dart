import 'package:uuid/uuid.dart';

/// A button displayed on the CarPlay Now Playing screen.
/// 
/// Use this to add custom actions like favorite/unfavorite to the Now Playing template.
class CPNowPlayingButton {
  /// Unique identifier for this button
  final String _elementId = const Uuid().v4();

  /// The SF Symbol name for the button image (e.g., "heart", "heart.fill")
  final String systemImageName;

  /// Whether the button is currently enabled
  final bool isEnabled;

  /// Callback when the button is pressed
  final Function()? onPress;

  /// Creates a Now Playing button with a system image.
  /// 
  /// [systemImageName] - SF Symbol name (e.g., "heart", "heart.fill", "star", "star.fill")
  /// [isEnabled] - Whether the button is interactive (default: true)
  /// [onPress] - Callback function when button is tapped
  CPNowPlayingButton({
    required this.systemImageName,
    this.isEnabled = true,
    this.onPress,
  });

  String get uniqueId => _elementId;

  Map<String, dynamic> toJson() => {
    "_elementId": _elementId,
    "systemImageName": systemImageName,
    "isEnabled": isEnabled,
  };
}
