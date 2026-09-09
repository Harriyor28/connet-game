import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus_link/core/constants/app_dimensions.dart';
import 'package:nexus_link/models/game_state.dart';
import 'package:nexus_link/models/node_model.dart';
import 'package:nexus_link/providers/game_provider.dart';
import 'package:nexus_link/rendering/connection_painter.dart';
import 'package:nexus_link/rendering/node_painter.dart';
import 'package:nexus_link/world/obstacle_definition.dart';
import 'package:nexus_link/world/world_definition.dart';

/// The interactive board where nodes and connections are rendered and interacted with.
class PuzzleBoard extends StatefulWidget {
  final WorldTheme theme;

  const PuzzleBoard({super.key, this.theme = WorldTheme.neonLab});

  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Offset? _dragPosition; // Current finger position in board coordinates

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final state = game.state;

    if (state == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate a square playing area centered within available space
        final boardSize =
            min(constraints.maxWidth, constraints.maxHeight) -
            (AppDimensions.boardMinMargin * 2);
        final clampedBoardSize = max(200.0, boardSize);

        final boardOffset = Offset(
          (constraints.maxWidth - clampedBoardSize) / 2,
          (constraints.maxHeight - clampedBoardSize) / 2,
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) =>
              _onPanStart(details, game, state, clampedBoardSize, boardOffset),
          onPanUpdate: (details) =>
              _onPanUpdate(details, game, state, clampedBoardSize, boardOffset),
          onPanEnd: (details) =>
              _onPanEnd(details, game, state, clampedBoardSize, boardOffset),
          onPanCancel: () => _onPanCancel(game),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _BoardPainter(
                  state: state,
                  boardSize: Size(clampedBoardSize, clampedBoardSize),
                  boardOffset: boardOffset,
                  dragPosition: _dragPosition,
                  pulseValue: _pulseController.value,
                  theme: widget.theme,
                ),
              );
            },
          ),
        );
      },
    );
  }

  NodeModel? _findNodeAt(
    Offset touchPosition,
    List<NodeModel> nodes,
    double boardSize,
    Offset boardOffset,
  ) {
    for (final node in nodes) {
      final projected = _projectNode(
        node,
        Size(boardSize, boardSize),
        boardOffset,
      );
      if ((touchPosition - projected.position).distance <=
          AppDimensions.nodeHitRadius * projected.scale) {
        return node;
      }
    }
    return null;
  }

  void _onPanStart(
    DragStartDetails details,
    GameProvider game,
    GameState state,
    double boardSize,
    Offset boardOffset,
  ) {
    if (!game.isPlaying) return;

    final touchPos = details.localPosition;
    final touchedNode = _findNodeAt(
      touchPos,
      state.nodes,
      boardSize,
      boardOffset,
    );

    if (touchedNode != null && touchedNode.canConnect) {
      final success = game.startDrag(touchedNode.id);
      if (success) {
        setState(() {
          _dragPosition = touchPos;
        });
      }
    }
  }

  void _onPanUpdate(
    DragUpdateDetails details,
    GameProvider game,
    GameState state,
    double boardSize,
    Offset boardOffset,
  ) {
    if (!game.isPlaying || game.activeNodeId == null) return;

    final touchPos = details.localPosition;
    setState(() {
      _dragPosition = touchPos;
    });

    final hoveredNode = _findNodeAt(
      touchPos,
      state.nodes,
      boardSize,
      boardOffset,
    );
    if (hoveredNode != null && hoveredNode.id != game.activeNodeId) {
      game.updateHover(hoveredNode.id);
    } else {
      game.updateHover(null);
    }
  }

  void _onPanEnd(
    DragEndDetails details,
    GameProvider game,
    GameState state,
    double boardSize,
    Offset boardOffset,
  ) {
    if (!game.isPlaying || game.activeNodeId == null) {
      setState(() => _dragPosition = null);
      return;
    }

    if (_dragPosition != null) {
      final targetNode = _findNodeAt(
        _dragPosition!,
        state.nodes,
        boardSize,
        boardOffset,
      );
      if (targetNode != null && targetNode.id != game.activeNodeId) {
        game.attemptConnection(targetNode.id);
      } else {
        game.cancelDrag();
      }
    } else {
      game.cancelDrag();
    }

    setState(() {
      _dragPosition = null;
    });
  }

  void _onPanCancel(GameProvider game) {
    game.cancelDrag();
    setState(() {
      _dragPosition = null;
    });
  }
}

class _ProjectedNode {
  final Offset position;
  final double scale;

  const _ProjectedNode(this.position, this.scale);
}

_ProjectedNode _projectNode(
  NodeModel node,
  Size boardSize,
  Offset boardOffset,
) {
  final center =
      boardOffset + Offset(boardSize.width / 2, boardSize.height / 2);
  final flat =
      boardOffset +
      Offset(
        node.normalizedX * boardSize.width,
        node.normalizedY * boardSize.height,
      );
  final perspective = (1.0 + node.normalizedZ * 0.24).clamp(0.78, 1.24);
  final position =
      center +
      (flat - center) * perspective +
      Offset(0, -node.normalizedZ * boardSize.height * 0.08);
  return _ProjectedNode(position, perspective);
}

/// Painter that renders all connections and nodes onto the board.
class _BoardPainter extends CustomPainter {
  final GameState state;
  final Size boardSize;
  final Offset boardOffset;
  final Offset? dragPosition;
  final double pulseValue;
  final WorldTheme theme;

  _BoardPainter({
    required this.state,
    required this.boardSize,
    required this.boardOffset,
    required this.dragPosition,
    required this.pulseValue,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBoardSurface(canvas);
    _drawObstacles(canvas);

    // 2. Draw Locked / Existing Connections
    for (final connection in state.activeConnections) {
      final fromNode = state.getNode(connection.fromNodeId);
      final toNode = state.getNode(connection.toNodeId);

      if (fromNode != null && toNode != null) {
        final start = _projectNode(fromNode, boardSize, boardOffset).position;
        final end = _projectNode(toNode, boardSize, boardOffset).position;

        final painter = ConnectionPainter(
          start: start,
          end: end,
          isLocked: connection.isLocked,
          isPreview: false,
          animationProgress: connection.animationProgress,
          glowPulse: pulseValue,
        );
        painter.paint(canvas, size);
      }
    }

    // 3. Draw Preview Cable during active drag
    if (state.activeNodeId != null && dragPosition != null) {
      final activeNode = state.getNode(state.activeNodeId!);
      if (activeNode != null) {
        final start = _projectNode(activeNode, boardSize, boardOffset).position;
        final isInvalidHover =
            state.hoverNodeId != null &&
            !state.isConnectionAllowed(state.activeNodeId!, state.hoverNodeId!);

        final painter = ConnectionPainter(
          start: start,
          end: dragPosition!,
          isLocked: false,
          isPreview: true,
          isInvalid: isInvalidHover,
          animationProgress: 1.0,
          glowPulse: pulseValue,
        );
        painter.paint(canvas, size);
      }
    }

    // 4. Draw Nodes
    final nodesByDepth = [...state.nodes]
      ..sort((a, b) => a.normalizedZ.compareTo(b.normalizedZ));
    for (final node in nodesByDepth) {
      final projected = _projectNode(node, boardSize, boardOffset);
      final nodePos = projected.position;
      final radius = AppDimensions.nodeRadius * projected.scale;
      final nodeSize = Size(radius * 2, radius * 2);

      canvas.save();
      // Translate to node top-left so painter can paint within its bounds
      canvas.translate(nodePos.dx - radius, nodePos.dy - radius);

      final isHovered = state.hoverNodeId == node.id;
      final isActive = state.activeNodeId == node.id;

      final painter = NodePainter(
        state: node.state,
        type: node.type,
        pulseAnimation: (isActive || isHovered) ? pulseValue : 0.0,
        scaleAnimation: (isActive || isHovered) ? 1.08 : 1.0,
        visualScale: projected.scale,
      );
      painter.paint(canvas, nodeSize);
      canvas.restore();
    }
  }

  void _drawBoardSurface(Canvas canvas) {
    final frameRect = Rect.fromLTWH(
      boardOffset.dx,
      boardOffset.dy,
      boardSize.width,
      boardSize.height,
    );

    final surfacePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.boardTop.withValues(alpha: 0.82),
          theme.boardBottom.withValues(alpha: 0.94),
        ],
      ).createShader(frameRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(24)),
      surfacePaint,
    );

    // A receding grid gives the board a real depth cue without a heavy 3D engine.
    final gridPaint = Paint()
      ..color = theme.accent.withValues(alpha: 0.09)
      ..strokeWidth = 1;
    for (var i = 1; i < 6; i++) {
      final fraction = i / 6;
      final x = frameRect.left + frameRect.width * fraction;
      final y = frameRect.top + frameRect.height * fraction;
      canvas.drawLine(
        Offset(x, frameRect.top),
        Offset(x, frameRect.bottom),
        gridPaint,
      );
      canvas.drawLine(
        Offset(frameRect.left, y),
        Offset(frameRect.right, y),
        gridPaint,
      );
    }

    // Subtle boundary glow.
    final rrect = RRect.fromRectAndRadius(frameRect, const Radius.circular(24));
    final framePaint = Paint()
      ..color = theme.accent.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(rrect, framePaint);

    // Corner decorative accents
    final cornerLength = 20.0;
    final cornerPaint = Paint()
      ..color = theme.accent.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Top-left
    canvas.drawLine(
      Offset(frameRect.left, frameRect.top + cornerLength),
      Offset(frameRect.left, frameRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.left, frameRect.top),
      Offset(frameRect.left + cornerLength, frameRect.top),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(frameRect.right - cornerLength, frameRect.top),
      Offset(frameRect.right, frameRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.right, frameRect.top),
      Offset(frameRect.right, frameRect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(frameRect.left, frameRect.bottom - cornerLength),
      Offset(frameRect.left, frameRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.left, frameRect.bottom),
      Offset(frameRect.left + cornerLength, frameRect.bottom),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(frameRect.right - cornerLength, frameRect.bottom),
      Offset(frameRect.right, frameRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.right, frameRect.bottom),
      Offset(frameRect.right, frameRect.bottom - cornerLength),
      cornerPaint,
    );
  }

  void _drawObstacles(Canvas canvas) {
    for (final obstacle in state.level.obstacles) {
      final bounds = obstacle.bounds;
      final obstacleRect = Rect.fromLTRB(
        boardOffset.dx + bounds.left * boardSize.width,
        boardOffset.dy + bounds.top * boardSize.height,
        boardOffset.dx + bounds.right * boardSize.width,
        boardOffset.dy + bounds.bottom * boardSize.height,
      );
      final color = obstacle.type == ObstacleType.energyBarrier
          ? theme.secondaryAccent
          : theme.accent;
      final fill = Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill;
      final border = Paint()
        ..color = color.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final shape = RRect.fromRectAndRadius(
        obstacleRect,
        const Radius.circular(10),
      );
      canvas.drawRRect(shape, fill);
      canvas.drawRRect(shape, border);
    }
  }

  @override
  bool shouldRepaint(_BoardPainter oldDelegate) => true;
}
