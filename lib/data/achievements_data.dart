import 'package:flutter/material.dart';

import '../services/stats_service.dart';
import '../theme.dart';

/// A single unlockable achievement, evaluated live against a [StatsSnapshot].
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool Function(StatsSnapshot s) test;
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.test,
  });

  bool earned(StatsSnapshot s) => test(s);
}

/// Curated list of achievements. Conditions are stable functions of a
/// [StatsSnapshot] — no separate persistence is required.
const achievements = <Achievement>[
  // ─── Onboarding ────────────────────────────────────────────────────
  Achievement(
    id: 'first_step',
    title: 'First step',
    description: 'Open the app for the first time.',
    icon: Icons.flag_outlined,
    color: AppColors.primary,
    test: _earnedFirstStep,
  ),

  // ─── Lessons ───────────────────────────────────────────────────────
  Achievement(
    id: 'apprentice_reader',
    title: 'Apprentice reader',
    description: 'Open 5 lessons.',
    icon: Icons.menu_book,
    color: AppColors.primary,
    test: _earnedApprenticeReader,
  ),
  Achievement(
    id: 'time_served_reader',
    title: 'Time-served reader',
    description: 'Open 25 lessons.',
    icon: Icons.auto_stories,
    color: AppColors.primary,
    test: _earnedTimeServedReader,
  ),
  Achievement(
    id: 'lesson_completionist',
    title: 'Library complete',
    description: 'Open every lesson in the library.',
    icon: Icons.local_library,
    color: Colors.amber,
    test: _earnedLessonCompletionist,
  ),

  // ─── Simulations ──────────────────────────────────────────────────
  Achievement(
    id: 'first_simulation',
    title: 'On the bench',
    description: 'Open your first simulation.',
    icon: Icons.play_circle,
    color: AppColors.accent,
    test: _earnedFirstSim,
  ),
  Achievement(
    id: 'sim_engineer',
    title: 'On the tools',
    description: 'Open 10 simulations.',
    icon: Icons.handyman,
    color: AppColors.accent,
    test: _earnedSimEngineer,
  ),
  Achievement(
    id: 'sim_master',
    title: 'Sim master',
    description: 'Open 30 simulations.',
    icon: Icons.engineering,
    color: AppColors.accent,
    test: _earnedSimMaster,
  ),

  // ─── Scenarios ─────────────────────────────────────────────────────
  Achievement(
    id: 'on_the_job',
    title: 'On the job',
    description: 'Open your first call-out scenario.',
    icon: Icons.work_history,
    color: Color(0xFFD62828),
    test: _earnedOnTheJob,
  ),
  Achievement(
    id: 'scenario_full_set',
    title: 'Five-job day',
    description: 'Open every job scenario.',
    icon: Icons.workspace_premium,
    color: Color(0xFFD62828),
    test: _earnedScenarioFullSet,
  ),

  // ─── Quizzes ───────────────────────────────────────────────────────
  Achievement(
    id: 'first_quiz',
    title: 'Quiz beginner',
    description: 'Attempt your first quiz topic.',
    icon: Icons.quiz,
    color: Color(0xFFE76F51),
    test: _earnedFirstQuiz,
  ),
  Achievement(
    id: 'quiz_century',
    title: 'Hundred up',
    description: 'Score 100 points across all quiz topics.',
    icon: Icons.emoji_events,
    color: Colors.amber,
    test: _earnedQuizCentury,
  ),
  Achievement(
    id: 'quiz_completionist',
    title: 'Quiz master',
    description: 'Attempt every quiz topic at least once.',
    icon: Icons.school,
    color: Color(0xFFE76F51),
    test: _earnedQuizCompletionist,
  ),

  // ─── Streaks ───────────────────────────────────────────────────────
  Achievement(
    id: 'streak_3',
    title: 'Daily habit',
    description: 'Open the app three days running.',
    icon: Icons.local_fire_department,
    color: AppColors.gas,
    test: _earnedStreak3,
  ),
  Achievement(
    id: 'streak_7',
    title: 'A full week',
    description: 'Open the app seven days running.',
    icon: Icons.local_fire_department,
    color: AppColors.gas,
    test: _earnedStreak7,
  ),
  Achievement(
    id: 'streak_30',
    title: 'Iron will',
    description: 'Maintain a 30-day streak.',
    icon: Icons.local_fire_department,
    color: Colors.deepOrange,
    test: _earnedStreak30,
  ),

  // ─── Bookmarks & specialism breadth ────────────────────────────────
  Achievement(
    id: 'bookmarks_5',
    title: 'Keeper of notes',
    description: 'Save 5 bookmarks.',
    icon: Icons.bookmark,
    color: AppColors.coldWater,
    test: _earnedBookmarks5,
  ),
  Achievement(
    id: 'bookmarks_25',
    title: 'Library curator',
    description: 'Save 25 bookmarks.',
    icon: Icons.bookmarks,
    color: AppColors.coldWater,
    test: _earnedBookmarks25,
  ),
  Achievement(
    id: 'specialism_explorer',
    title: 'Specialism explorer',
    description: 'Open 4 different specialism hubs.',
    icon: Icons.travel_explore,
    color: Color(0xFF073B4C),
    test: _earnedSpecialismExplorer,
  ),
];

// ─── Predicate functions (top-level so they remain const-friendly) ──

bool _earnedFirstStep(StatsSnapshot s) => true;
bool _earnedApprenticeReader(StatsSnapshot s) => s.lessonsRead >= 5;
bool _earnedTimeServedReader(StatsSnapshot s) => s.lessonsRead >= 25;
bool _earnedLessonCompletionist(StatsSnapshot s) =>
    s.totalLessons > 0 && s.lessonsRead >= s.totalLessons;
bool _earnedFirstSim(StatsSnapshot s) => s.simsWatched >= 1;
bool _earnedSimEngineer(StatsSnapshot s) => s.simsWatched >= 10;
bool _earnedSimMaster(StatsSnapshot s) => s.simsWatched >= 30;
bool _earnedOnTheJob(StatsSnapshot s) => s.scenariosOpened >= 1;
bool _earnedScenarioFullSet(StatsSnapshot s) =>
    s.totalScenarios > 0 && s.scenariosOpened >= s.totalScenarios;
bool _earnedFirstQuiz(StatsSnapshot s) => s.quizTopicsAttempted >= 1;
bool _earnedQuizCentury(StatsSnapshot s) => s.quizBestCorrectTotal >= 100;
bool _earnedQuizCompletionist(StatsSnapshot s) =>
    s.totalQuizTopics > 0 && s.quizTopicsAttempted >= s.totalQuizTopics;
bool _earnedStreak3(StatsSnapshot s) => s.currentStreak >= 3;
bool _earnedStreak7(StatsSnapshot s) => s.currentStreak >= 7;
bool _earnedStreak30(StatsSnapshot s) => s.currentStreak >= 30;
bool _earnedBookmarks5(StatsSnapshot s) => s.bookmarksCount >= 5;
bool _earnedBookmarks25(StatsSnapshot s) => s.bookmarksCount >= 25;
bool _earnedSpecialismExplorer(StatsSnapshot s) => s.hubsVisited >= 4;
