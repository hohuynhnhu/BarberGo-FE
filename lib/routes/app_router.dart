  import 'package:barbergofe/core/utils/intro_service.dart';
import 'package:barbergofe/routes/route_names.dart';
import 'package:barbergofe/views/auth/SignUp_page.dart';
  import 'package:barbergofe/views/not_found_page.dart';
  import 'package:go_router/go_router.dart';
  import 'package:barbergofe/views/auth/login_page.dart';
  import 'package:barbergofe/views/intro/Screen_intro.dart';
  final GoRouter appRouter = GoRouter(
      initialLocation: RouteNames.getStarted,
      routes:[
        GoRoute(
            path:RouteNames.login,
            name: 'login',
            builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/',
          name: 'intro',
          builder: (context, state) => const IntroScreen(),
        ),
        GoRoute(
          path: RouteNames.signup,
          name: 'signup',
          builder: (context, state) => const SignupPage(),
        ),
      ],   errorBuilder: (context, state) => const NotFoundPage(),
      redirect: (context, state) async{
        //kiểm tra intro
        bool seen =await IntroService.isIntroSeen();
        //nếu chưa xem thì chuyển sang intro
        if(!seen){
          return RouteNames.getStarted;
        }
        return RouteNames.signup;
      }

  );
