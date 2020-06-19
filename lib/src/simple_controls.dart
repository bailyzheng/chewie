import 'dart:async';

import 'package:chewie/src/chewie_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SimpleControls extends StatefulWidget {
  const SimpleControls({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SimpleControlsState();
  }
}

class _SimpleControlsState extends State<SimpleControls> {
  VideoPlayerValue _latestValue;
  bool _dragging = false;
  VideoPlayerController controller;
  ChewieController chewieController;

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder(
              context,
              chewieController.videoPlayerController.value.errorDescription,
            )
          : Center(
              child: Icon(
                Icons.error,
                color: Colors.red,
                size: 42,
              ),
            );
    }

    return MouseRegion(
      onHover: (_) {
      },
      child: GestureDetector(
        onTap: () {
          _playPause();
        },
        child: AbsorbPointer(
          child: Column(
            children: <Widget>[
              _latestValue != null &&
                          !_latestValue.isPlaying &&
                          _latestValue.duration == null ||
                      _latestValue.isBuffering
                  ? const Expanded(
                      child: const Center(
                        child: const CircularProgressIndicator(),
                      ),
                    )
                  : _buildHitArea(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("simple_controls dispose");
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
  }

  @override
  void didChangeDependencies() {
    final _oldController = chewieController;
    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (_oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  Expanded _buildHitArea() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_latestValue != null && _latestValue.isPlaying) {
          } else {
            _playPause();
          }
        },
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: AnimatedOpacity(
              opacity:
                  _latestValue != null && !_latestValue.isPlaying && !_dragging
                      ? 1.0
                      : 0.0,
              duration: Duration(milliseconds: 300),
              child: GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).dialogBackgroundColor,
                    borderRadius: BorderRadius.circular(38.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.play_arrow, size: 32.0, color: Colors.white,),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> _initialize() async {
    controller.addListener(_updateState);

    _updateState();

    if ((controller.value != null && controller.value.isPlaying) ||
        chewieController.autoPlay) {
    }
  }

  void _playPause() {
    bool isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        if (!controller.value.initialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration(seconds: 0));
          }
          controller.play();
        }
      }
    });
  }

  void _updateState() {
    if (mounted) {
      setState(() {
        _latestValue = controller.value;
      });
    }
  }
}
