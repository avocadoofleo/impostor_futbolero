import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:impostor_futbolero/ui/screens/home_screen.dart';
import 'package:impostor_futbolero/ui/screens/lobby_screen.dart';
import 'package:impostor_futbolero/ui/screens/find_game_screen.dart';
import 'package:impostor_futbolero/ui/screens/gameplay/gameplay_screen.dart';
import 'package:impostor_futbolero/ui/screens/local_setup_screen.dart';
import 'package:impostor_futbolero/ui/screens/gameplay/role_assignment_screen.dart';
import 'package:impostor_futbolero/ui/screens/gameplay/clue_giving_screen.dart';
import 'package:impostor_futbolero/ui/screens/gameplay/discussion_phase_screen.dart';
import 'package:impostor_futbolero/ui/screens/gameplay/voting_phase_screen.dart';
import 'package:impostor_futbolero/ui/screens/gameplay/results_phase_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/', 
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/find-game',
      builder: (BuildContext context, GoRouterState state) {
        return const FindGameScreen();
      },
    ),
    GoRoute(
      path: '/local-setup',
      builder: (BuildContext context, GoRouterState state) {
        return const LocalSetupScreen();
      },
    ),
    GoRoute(
      path: '/role-assignment/:playerIndex',
      builder: (BuildContext context, GoRouterState state) {
        final playerIndex = int.parse(state.pathParameters['playerIndex']!);
        final extra = state.extra as Map<String, dynamic>;
        final players = extra['players'] as List<String>;
        final secretWord = extra['secretWord'] as String?;
        final impostorIndex = extra['impostorIndex'] as int?;

        return RoleAssignmentScreen(
          key: ValueKey(playerIndex), // Force rebuild when playerIndex changes
          players: players,
          currentPlayerIndex: playerIndex,
          secretWord: secretWord,
          impostorIndex: impostorIndex,
        );
      },
    ),
    GoRoute(
      path: '/game-loop/:playerIndex',
      builder: (BuildContext context, GoRouterState state) {
        final playerIndex = int.parse(state.pathParameters['playerIndex']!);
        final extra = state.extra as Map<String, dynamic>;
        return ClueGivingScreen(
          players: extra['players'] as List<String>,
          currentPlayerIndex: playerIndex,
          secretWord: extra['secretWord'] as String,
          impostorIndex: extra['impostorIndex'] as int,
        );
      },
    ),
    GoRoute(
      path: '/discussion',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>;
        return DiscussionPhaseScreen(
          players: extra['players'] as List<String>,
          secretWord: extra['secretWord'] as String,
          impostorIndex: extra['impostorIndex'] as int,
        );
      },
    ),
    GoRoute(
      path: '/voting/:playerIndex',
      builder: (BuildContext context, GoRouterState state) {
        final playerIndex = int.parse(state.pathParameters['playerIndex']!);
        final extra = state.extra as Map<String, dynamic>;
        return VotingPhaseScreen(
          players: extra['players'] as List<String>,
          currentPlayerIndex: playerIndex,
          secretWord: extra['secretWord'] as String,
          impostorIndex: extra['impostorIndex'] as int,
          votes: extra['votes'] as Map<int, int>,
        );
      },
    ),
    GoRoute(
      path: '/results',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>;
        return ResultsPhaseScreen(
          players: extra['players'] as List<String>,
          secretWord: extra['secretWord'] as String,
          impostorIndex: extra['impostorIndex'] as int,
          votes: extra['votes'] as Map<int, int>,
        );
      },
    ),
    GoRoute(
      path: '/lobby/:gameId',
      builder: (BuildContext context, GoRouterState state) {
        final gameId = state.pathParameters['gameId']!;
        return LobbyScreen(gameId: gameId);
      },
    ),
    GoRoute(
      path: '/game/:gameId',
      builder: (BuildContext context, GoRouterState state) {
        final gameId = state.pathParameters['gameId']!;
        return GameplayScreen(gameId: gameId);
      },
    ),
  ],
);
