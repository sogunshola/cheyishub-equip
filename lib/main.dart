import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/localization_repository.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/bloc/assignment/assignment_bloc.dart';
import 'package:masterstudy_app/ui/bloc/category_detail/bloc.dart';
import 'package:masterstudy_app/ui/bloc/course/bloc.dart';
import 'package:masterstudy_app/ui/bloc/courses/bloc.dart';
import 'package:masterstudy_app/ui/bloc/detail_profile/bloc.dart';
import 'package:masterstudy_app/ui/bloc/edit_profile_bloc/bloc.dart';
import 'package:masterstudy_app/ui/bloc/favorites/bloc.dart';
import 'package:masterstudy_app/ui/bloc/final/bloc.dart';
import 'package:masterstudy_app/ui/bloc/home/bloc.dart';
import 'package:masterstudy_app/ui/bloc/home_simple/bloc.dart';
import 'package:masterstudy_app/ui/bloc/lesson_stream/bloc.dart';
import 'package:masterstudy_app/ui/bloc/lesson_video/bloc.dart';
import 'package:masterstudy_app/ui/bloc/orders/orders_bloc.dart';
import 'package:masterstudy_app/ui/bloc/plans/plans_bloc.dart';
import 'package:masterstudy_app/ui/bloc/profile/bloc.dart';
import 'package:masterstudy_app/ui/bloc/profile_assignment/profile_assignment_bloc.dart';
import 'package:masterstudy_app/ui/bloc/question_ask/bloc.dart';
import 'package:masterstudy_app/ui/bloc/question_details/bloc.dart';
import 'package:masterstudy_app/ui/bloc/questions/bloc.dart';
import 'package:masterstudy_app/ui/bloc/quiz_lesson/quiz_lesson_bloc.dart';
import 'package:masterstudy_app/ui/bloc/quiz_screen/quiz_screen_bloc.dart';
import 'package:masterstudy_app/ui/bloc/restore_password/restore_password_bloc.dart';
import 'package:masterstudy_app/ui/bloc/review_write/bloc.dart';
import 'package:masterstudy_app/ui/bloc/search/bloc.dart';
import 'package:masterstudy_app/ui/bloc/search_detail/bloc.dart';
import 'package:masterstudy_app/ui/bloc/text_lesson/bloc.dart';
import 'package:masterstudy_app/ui/bloc/user_course/bloc.dart';
import 'package:masterstudy_app/ui/bloc/user_course_locked/bloc.dart';
import 'package:masterstudy_app/ui/bloc/video/bloc.dart';
import 'package:masterstudy_app/ui/screen/assignment/assignment_screen.dart';
import 'package:masterstudy_app/ui/screen/auth/auth_screen.dart';
import 'package:masterstudy_app/ui/screen/category_detail/category_detail_screen.dart';
import 'package:masterstudy_app/ui/screen/course/course_screen.dart';
import 'package:masterstudy_app/ui/screen/detail_profile/detail_profile_screen.dart';
import 'package:masterstudy_app/ui/screen/final/final_screen.dart';
import 'package:masterstudy_app/ui/screen/lesson_stream/lesson_stream_screen.dart';
import 'package:masterstudy_app/ui/screen/lesson_video/lesson_video_screen.dart';
import 'package:masterstudy_app/ui/screen/main/main_screen.dart';
import 'package:masterstudy_app/ui/screen/plans/plans_screen.dart';
import 'package:masterstudy_app/ui/screen/profile_assignment/profile_assignment_screen.dart';
import 'package:masterstudy_app/ui/screen/profile_edit/profile_edit_screen.dart';
import 'package:masterstudy_app/ui/screen/question_ask/question_ask_screen.dart';
import 'package:masterstudy_app/ui/screen/question_details/question_details_screen.dart';
import 'package:masterstudy_app/ui/screen/questions/questions_screen.dart';
import 'package:masterstudy_app/ui/screen/quiz_lesson/quiz_lesson_screen.dart';
import 'package:masterstudy_app/ui/screen/quiz_screen/quiz_screen.dart';
import 'package:masterstudy_app/ui/screen/restore_password/restore_password_screen.dart';
import 'package:masterstudy_app/ui/screen/review_write/review_write_screen.dart';
import 'package:masterstudy_app/ui/screen/search_detail/search_detail_screen.dart';
import 'package:masterstudy_app/ui/screen/splash/splash_screen.dart';
import 'package:masterstudy_app/ui/screen/text_lesson/text_lesson_screen.dart';
import 'package:masterstudy_app/ui/screen/user_course/user_course.dart';
import 'package:masterstudy_app/ui/screen/user_course_locked/user_course_locked_screen.dart';
import 'package:masterstudy_app/ui/screen/video_screen/video_screen.dart';
import 'package:masterstudy_app/ui/screen/web_checkout/web_checkout_screen.dart';
import 'package:masterstudy_app/ui/widgets/message_notification.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/cache/cache_manager.dart';
import 'data/push/push_manager.dart';
import 'di/app_injector.dart';
import 'ui/screen/orders/orders.dart';
import 'ui/screen/user_course/user_course.dart';

typedef Provider<T> = T Function();

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

LocalizationRepository localizations;
Color mainColor, mainColorA, secondColor;

StreamController<Map<String, dynamic>> pushStreamController =
    StreamController<Map<String, dynamic>>();
Stream pushStream = pushStreamController.stream.asBroadcastStream();

bool dripContentEnabled = false;
bool demoEnabled = false;
bool appView = false;

AndroidDeviceInfo androidInfo;

var iosInfo;

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }
  // Or do other work.
}

Directory appDocDir;

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarColor: Colors.grey.withOpacity(0.4), //top bar color
    statusBarIconBrightness: Brightness.light, //top bar icons
  ));

  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  WidgetsFlutterBinding.ensureInitialized();
  localizations = LocalizationRepositoryImpl(await getDefaultLocalization());
  final SharedPreferences _sharedPreferences =
      await SharedPreferences.getInstance();
  appView = _sharedPreferences.getBool("app_view") ?? false;
  await setColors();
  if (Platform.isAndroid) androidInfo = await DeviceInfoPlugin().androidInfo;
  if (Platform.isIOS) iosInfo = await DeviceInfoPlugin().iosInfo;
  PushNotificationsManager().init();
  appDocDir = await getApplicationDocumentsDirectory();
  runZoned(() async {
    var container = await AppInjector.create();

    runApp(container.app);
  }, onError: Crashlytics.instance.recordError);
}

Future<bool> setColors() async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  try {
    final mcr = sharedPreferences.getInt("main_color_r");
    final mcg = sharedPreferences.getInt("main_color_g");
    final mcb = sharedPreferences.getInt("main_color_b");
    final mca = sharedPreferences.getDouble("main_color_a");

    final scr = sharedPreferences.getInt("second_color_r");
    final scg = sharedPreferences.getInt("second_color_g");
    final scb = sharedPreferences.getInt("second_color_b");
    final sca = sharedPreferences.getDouble("second_color_a");

    mainColor = Color.fromRGBO(mcr, mcg, mcb, mca);
    mainColorA = Color.fromRGBO(mcr, mcg, mcb, 0.999);
    secondColor = Color.fromRGBO(scr, scg, scb, sca);
  } catch (e) {
    mainColor = blue_blue;
    mainColorA = blue_blue_a;
    secondColor = seaweed;
  }
  return true;
}

Future<String> getDefaultLocalization() async {
  String data =
      await rootBundle.loadString('assets/localization/default_locale.json');
  return data;
}

String appLogoUrl;

@provide
class MyApp extends StatefulWidget {
  final Provider<AuthScreen> authScreen;
  final Provider<HomeBloc> homeBloc;
  final Provider<FavoritesBloc> favoritesBloc;
  final Provider<SplashScreen> splashScreen;
  final Provider<ProfileBloc> profileBloc;
  final Provider<DetailProfileBloc> detailProfileBloc;
  final Provider<EditProfileBloc> editProfileBloc;
  final Provider<SearchScreenBloc> searchScreenBloc;
  final Provider<SearchDetailBloc> searchDetailBloc;
  final Provider<CourseBloc> courseBloc;
  final Provider<HomeSimpleBloc> homeSimpleBloc;
  final Provider<CategoryDetailBloc> categoryDetailBloc;
  final Provider<AssignmentBloc> assignmentBloc;
  final Provider<ProfileAssignmentBloc> profileAssignmentBloc;
  final Provider<ReviewWriteBloc> reviewWriteBloc;
  final Provider<UserCoursesBloc> userCoursesBloc;
  final Provider<UserCourseBloc> userCourseBloc;
  final Provider<UserCourseLockedBloc> userCourseLockedBloc;
  final Provider<TextLessonBloc> textLessonBloc;
  final Provider<LessonVideoBloc> lessonVideoBloc;
  final Provider<LessonStreamBloc> lessonStreamBloc;
  final Provider<VideoBloc> videoBloc;
  final Provider<QuizLessonBloc> quizLessonBloc;
  final Provider<QuestionsBloc> questionsBloc;
  final Provider<QuestionAskBloc> questionAskBloc;
  final Provider<QuestionDetailsBloc> questionDetailsBloc;
  final Provider<QuizScreenBloc> quizScreenBloc;
  final Provider<FinalBloc> finalBloc;
  final Provider<PlansBloc> plansBloc;
  final Provider<OrdersBloc> ordersBloc;
  final Provider<RestorePasswordBloc> restorePasswordBloc;

  const MyApp(
    this.authScreen,
    this.homeBloc,
    this.splashScreen,
    this.favoritesBloc,
    this.profileBloc,
    this.editProfileBloc,
    this.detailProfileBloc,
    this.searchScreenBloc,
    this.searchDetailBloc,
    this.courseBloc,
    this.homeSimpleBloc,
    this.categoryDetailBloc,
    this.profileAssignmentBloc,
    this.assignmentBloc,
    this.reviewWriteBloc,
    this.userCoursesBloc,
    this.userCourseBloc,
    this.userCourseLockedBloc,
    this.textLessonBloc,
    this.quizLessonBloc,
    this.lessonVideoBloc,
    this.lessonStreamBloc,
    this.videoBloc,
    this.questionsBloc,
    this.questionAskBloc,
    this.questionDetailsBloc,
    this.quizScreenBloc,
    this.finalBloc,
    this.plansBloc,
    this.ordersBloc,
    this.restorePasswordBloc,
  ) : super();

  _getProvidedMainScreen() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(create: (BuildContext context) => homeBloc()),
        BlocProvider<HomeSimpleBloc>(
            create: (BuildContext context) => homeSimpleBloc()),
        BlocProvider<FavoritesBloc>(
            create: (BuildContext context) => favoritesBloc()),
        BlocProvider<SearchScreenBloc>(
            create: (BuildContext context) => searchScreenBloc()),
        BlocProvider<UserCoursesBloc>(
            create: (BuildContext context) => userCoursesBloc()),
      ],
      child: MainScreen(),
    );
  }

  ThemeData _buildShrineTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      accentColor: mainColor,
      primaryColor: mainColor,
      buttonTheme: buttonThemeData,
      buttonBarTheme: base.buttonBarTheme.copyWith(
        buttonTextTheme: ButtonTextTheme.accent,
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
      ),
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      textTheme: getTextTheme(base.primaryTextTheme),
      primaryTextTheme: getTextTheme(base.primaryTextTheme).apply(
        bodyColor: mainColor,
        displayColor: mainColor,
      ),
      accentTextTheme: textTheme,
      textSelectionColor: mainColor.withOpacity(0.4),
      errorColor: Colors.red[400],
    );
  }

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  StreamSubscription<List<PurchaseDetails>> _subscription;

  /// Is the API available on the device
  bool _available = true;

  /// The In App Purchase plugin
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  /// Products for sale
  List<ProductDetails> _products = [];

  /// Past purchases
  List<PurchaseDetails> _purchases = [];

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  void _buyProduct(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    // _iap.buyNonConsumable(purchaseParam: purchaseParam);
    _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: false);
  }

  void _initialize() async {
    // Check availability of In App Purchases
    _available = await _iap.isAvailable();

    _subscription = _iap.purchaseUpdatedStream.listen((data) => setState(() {
          print('NEW PURCHASE');
          _purchases.addAll(data);
          //_verifyPurchase(data);
        }));

    if (_available) {
      await _getProducts();
      await _getPastPurchases();

      // Verify and deliver a purchase with your own business logic
      // _verifyPurchase();
    }
  }

  /// Get all products available for sale
  Future<void> _getProducts() async {
    Set<String> ids = Set.from(['test_a']);
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);

    setState(() {
      _products = response.productDetails;
    });
  }

  /// Gets past purchases
  Future<void> _getPastPurchases() async {
    QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();

    for (PurchaseDetails purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        InAppPurchaseConnection.instance.completePurchase(purchase);
      }
    }

    setState(() {
      _purchases = response.pastPurchases;
    });
  }

  /// Returns purchase of specific product ID
  PurchaseDetails _hasPurchased(String productID) {
    return _purchases.firstWhere((purchase) => purchase.productID == productID,
        orElse: () => null);
  }

  /// Your own business logic to setup a consumable
  void _verifyPurchase(String productID) {
    PurchaseDetails purchase = _hasPurchased(productID);

    // TODO serverside verification & record consumable in the database

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {}
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pushStream.listen((event) {
      var message = event as Map<String, dynamic>;
      var notification = message["notification"];
      showOverlayNotification((context) {
        return MessageNotification(
          notification["title"],
          notification["body"],
          onReplay: () {
            OverlaySupportEntry.of(context).dismiss();
          },
        );
      }, duration: Duration(seconds: 5));
    });
    return BlocProvider(
      create: (BuildContext context) => widget.profileBloc(),
      child: OverlaySupport(
        child: MaterialApp(
          title: 'Masterstudy',
          theme: widget._buildShrineTheme(),
          initialRoute: SplashScreen.routeName,
          debugShowCheckedModeBanner: false,
          // ignore: missing_return
          navigatorKey: navigatorKey,
          onGenerateRoute: (routeSettings) {
            switch (routeSettings.name) {
              case SplashScreen.routeName:
                // ignore: missing_return
                return MaterialPageRoute(
                    builder: (context) => widget.splashScreen());
              case AuthScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) => widget.authScreen(),
                    settings: routeSettings);
              case MainScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) => widget._getProvidedMainScreen(),
                    settings: routeSettings);
              case CourseScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) => CourseScreen(widget.courseBloc()),
                    settings: routeSettings);
              case SearchDetailScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) =>
                        SearchDetailScreen(widget.searchDetailBloc()),
                    settings: routeSettings);
              case DetailProfileScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) =>
                        DetailProfileScreen(widget.detailProfileBloc()),
                    settings: routeSettings);
              case ProfileEditScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) =>
                        ProfileEditScreen(widget.editProfileBloc()),
                    settings: routeSettings);
              case CategoryDetailScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) =>
                        CategoryDetailScreen(widget.categoryDetailBloc()),
                    settings: routeSettings);
              case ProfileAssignmentScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) =>
                        ProfileAssignmentScreen(widget.profileAssignmentBloc()),
                    settings: routeSettings);
              case AssignmentScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) =>
                        AssignmentScreen(widget.assignmentBloc()),
                    settings: routeSettings);
              case ReviewWriteScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) =>
                        ReviewWriteScreen(widget.reviewWriteBloc()),
                    settings: routeSettings);
              case UserCourseScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) => UserCourseScreen(
                          widget.userCourseBloc(),
                        ),
                    settings: routeSettings);
              case TextLessonScreen.routeName:
                return PageTransition(
                    child: TextLessonScreen(widget.textLessonBloc()),
                    type: PageTransitionType.leftToRight,
                    settings: routeSettings);
              case LessonVideoScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) =>
                        LessonVideoScreen(widget.lessonVideoBloc()),
                    settings: routeSettings);
              case LessonStreamScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) =>
                        LessonStreamScreen(widget.lessonStreamBloc()),
                    settings: routeSettings);
              case VideoScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) => VideoScreen(widget.videoBloc()),
                    settings: routeSettings);
              case QuizLessonScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) =>
                        QuizLessonScreen(widget.quizLessonBloc()),
                    settings: routeSettings);
              case QuestionsScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) =>
                        QuestionsScreen(widget.questionsBloc()),
                    settings: routeSettings);
              case QuestionAskScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) =>
                        QuestionAskScreen(widget.questionAskBloc()),
                    settings: routeSettings);
              case QuestionDetailsScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) =>
                        QuestionDetailsScreen(widget.questionDetailsBloc()),
                    settings: routeSettings);
              case FinalScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) => FinalScreen(widget.finalBloc()),
                    settings: routeSettings);
              case QuizScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) => QuizScreen(widget.quizScreenBloc()),
                    settings: routeSettings);
              case PlansScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) => PlansScreen(widget.plansBloc()),
                    settings: routeSettings);
              case WebCheckoutScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) => WebCheckoutScreen(),
                    settings: routeSettings);
              case OrdersScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) => OrdersScreen(widget.ordersBloc()),
                    settings: routeSettings);
              case UserCourseLockedScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) =>
                        UserCourseLockedScreen(widget.courseBloc()),
                    settings: routeSettings);
              case RestorePasswordScreen.routeName:
                return MaterialPageRoute(
                    builder: (context) =>
                        RestorePasswordScreen(widget.restorePasswordBloc()),
                    settings: routeSettings);
              default:
                return MaterialPageRoute(
                    builder: (context) => widget.splashScreen());
            }
          },
        ),
      ),
    );
  }
}
