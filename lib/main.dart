import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}
// StatelessWidget : 변경 가능한 상태를 포함하지 않아 MyAppState를 통한 상태관리가 필요함
class MyApp extends StatelessWidget {
  // MyApp 생성자, 부모 클래스(StatelessWidget)의 키를 전달
  // const를 통해 위젯이 변경되지 않게함
  // 시작 앱부터 위젯으로 시작함
  const MyApp({super.key});

  // build 메서드 : 위젯의 UI를 구성, UI 반환
  @override
  Widget build(BuildContext context) {
    // provider 패턴을 사용하여 상태관리를 위한 객체(MyAppState) 제공
    // 이를 통해 객체에 접근할 수 있음
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      // MaterialApp : 플러터 앱의 기본 구조를 제공하는 위젯
      child: MaterialApp(
        title: 'Namer App',
        // ThemeDate를 사용하여 앱의 테마 설정 (색상 및 스타일)
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        // 앱의 기본 홈 화면을 MyHomePage(밑에 추가로 생성한 위젯) 위젯으로 설정함
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // ChangeNotifier : 플러터의 상태 관리 객체, 변경시 UI 업데이트
  // current에 랜덤한 단어를 저장하고 상태변경시 notifyListeners() 메서드를 호출함
  var current = WordPair.random();


  void getNext() {
    Future.delayed(Duration(milliseconds: 200), () {
        current = WordPair.random();
        // 상태 변경을 적용하기 위한 리스너 호출
        notifyListeners();
    });

  }

  var favorites = <WordPair>[];

  // 좋아요 누른 단어가 이미 있으면 삭제, 없으면 추가
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void deleteFavorite(WordPair pair) {
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      // throw
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritePage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // UI의 뼈대를 잡아주는 위젯
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  // 화면의 넓이가 600이상 일때만 라벨을 표시함
                  extended: constraints.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                          icon: Icon(Icons.home),
                          label: Text('Home')
                      ),
                      NavigationRailDestination(
                          icon: Icon(Icons.favorite),
                          label: Text('Favorites')
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    // 네비게이션이 선택될때마다 실행되는 콜백함수
                    // notifyListeners와 유사함. 자동으로 상태가 적용됨
                    onDestinationSelected: (value) {
                      // 네비게이션 선택시 선택된 인덱스 값 변경
                      // 변경될 때마다 선택된 인덱스가 적용돼서 UI에 변화가 생김
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                ),
              ),
              // Expande : 필요한만큼만 공간을 차지하는 위젯
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              )
            ],
          )
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // MyAppState 클래스의 인스턴스를 가져옴.
    // 이를 통해 해당 클래스의 상태가 변경될 때 UI를 업데이트함
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    // 좋아요 누른 단어쌍이면 채운 하트 아이콘, 아니면 빈하트
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    // Scaffold는 Flutter에서 기본적인 레이아웃 구조를 제공하는 위젯
    // body는 scaffold위젯에서 화면의 주 콘텐츠 영역

    // Column : 여러 위젯을 수직 정렬하는 위젯 (div 같은건가?)
    // Text : 문자열 위젯 (<p> 같은건가?)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 중앙 배치
        children: [
          Text('A random AWESOME idea:'),
          BigCard(pair: pair),
          // SizedBox : 공간만 차지하는 아무것도 렌더링 하지 않는 간격을 위한 위젯
          SizedBox(height: 10),
          Row(
            // 사용 가능한 모든 가로 공간을 사용하지말라?는 의미?
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  icon: Icon(icon),
                  label: Text('favorite'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                  onPressed: () {
                    // 버튼을 누를때마다 새로운 단어 생성
                    appState.getNext();
                  },
                  child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    // 일관된 색상을 유지하기 위해 이미 지정한 테마를 상위 컨텍스트에서 가져옴
    final theme = Theme.of(context);

    // 스타일 설정 저장한 변수, 하나로 여러곳에 지정가능
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    // Wrap with Padding 리팩토링 선택하는법 커서 올린후 alt + enter
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: Text(
              pair.asLowerCase,
              style: style,
              // semanticsLabel : 보이는건 그대로 하면서 의미만 바꾸게 설정
              // 이를 통해 스크린 리더(음성 가이드)에서 붙어있는 단어쌍을 제대로 발음할 수 있음
              // ex) cheaphead (표시) -> cheap head (의미)
              semanticsLabel: "${pair.first} ${pair.second}",
          ),
        ),
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('You have ${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline),
              color: Colors.deepOrangeAccent,
              onPressed: () {
                appState.deleteFavorite(pair);
              },
            ),
          )
      ],
    );
  }



}