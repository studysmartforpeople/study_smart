import 'package:flutter/material.dart';

class AuthScreenFrame extends StatefulWidget {
  final String? appBarTitle;
  final String title;
  final String subtitle;
  final Widget child;
  final double maxWidth;

  const AuthScreenFrame({
    super.key,
    this.appBarTitle,
    required this.title,
    required this.subtitle,
    required this.child,
    this.maxWidth = 500,
  });

  @override
  State<AuthScreenFrame> createState() => _AuthScreenFrameState();
}

class _AuthScreenFrameState extends State<AuthScreenFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.045),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.32,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.error, width: 1.8),
          ),
        ),
      ),
      child: Scaffold(
        appBar: widget.appBarTitle == null
            ? null
            : AppBar(
                title: Text(widget.appBarTitle!),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
              ),
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.primary.withValues(alpha: 0.07),
                colorScheme.surface,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -90,
                right: -70,
                child: _BackgroundOrb(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  size: 230,
                ),
              ),
              Positioned(
                bottom: -100,
                left: -90,
                child: _BackgroundOrb(
                  color: colorScheme.secondary.withValues(alpha: 0.07),
                  size: 250,
                ),
              ),
              SafeArea(
                top: widget.appBarTitle == null,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: widget.maxWidth),
                      child: FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slide,
                          child: Card(
                            elevation: 3,
                            shadowColor: colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            color: colorScheme.surface,
                            surfaceTintColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                              side: BorderSide(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(26),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Center(child: AuthBrandMark()),
                                  const SizedBox(height: 22),
                                  Text(
                                    widget.title,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.subtitle,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                          height: 1.45,
                                        ),
                                  ),
                                  const SizedBox(height: 26),
                                  widget.child,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthBrandMark extends StatelessWidget {
  const AuthBrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.tertiary],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        'SDS',
        style: TextStyle(
          color: Colors.white,
          fontSize: 23,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _BackgroundOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
