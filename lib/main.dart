import "package:flutter/material.dart";
import "package:fridgital/widgets/mouse_scroll.dart";

void main() {
  runApp(const MyApp());
}

// ignore: always_specify_types
const colors = (textDark: Color(0xff2d2020),);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 45.0,
            fontWeight: FontWeight.bold,
            color: colors.textDark,
          ),
          titleMedium: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: colors.textDark,
          ),
          displayLarge: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
            color: colors.textDark,
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(255, 250, 227, 1.0),
                    Color.fromRGBO(247, 202, 201, 1.0),
                  ],
                ),
              ),
              child: MouseSingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeTitle(theme: theme),
                    NearingExpiry(theme: theme),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeTitle extends StatelessWidget {
  const HomeTitle({
    required this.theme,
    super.key,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hello,\n[User]!", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8.0),
          Text("Let's see what's in store for you!", style: theme.textTheme.displayLarge),
        ],
      ),
    );
  }
}

class NearingExpiry extends StatefulWidget {
  const NearingExpiry({
    required this.theme,
    super.key,
  });

  final ThemeData theme;

  @override
  State<NearingExpiry> createState() => _NearingExpiryState();
}

class _NearingExpiryState extends State<NearingExpiry> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    scrollController = new ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("nearing expiry", style: widget.theme.textTheme.titleMedium),
                const SizedBox(width: 8.0),
                SideButton(
                  onTap: () {
                    print("You pressed me my brother");
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              return false;
            },
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: UnconstrainedBox(
                child: Row(
                  children: [
                    for (int i = 0; i < 5; ++i)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 32.0),
                        color: const Color(0xff92a8d1),
                        child: Text("$i"),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SideButton extends StatelessWidget {
  const SideButton({
    required this.onTap,
    super.key,
  });

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleY: 0.75,
      child: Transform.translate(
        offset: const Offset(0, -12.0),
        child: GestureDetector(
          onTap: onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Icon(
              Icons.arrow_forward_ios,
              size: 22.0,
              color: colors.textDark.withAlpha(127),
            ),
          ),
        ),
      ),
    );
  }
}
