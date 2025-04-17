import 'package:flutter/material.dart';

import 'package:gdg_app/constants/routes.dart';
import 'package:gdg_app/views/admin/admin_access_form.dart';
import 'package:gdg_app/views/admin/admin_home_view.dart';
import 'package:gdg_app/views/admin/admin_manage_player_finances_view.dart';
import 'package:gdg_app/views/admin_player_coach_option.dart';
import 'package:gdg_app/views/admin/admin_register_admin_view.dart';
import 'package:gdg_app/views/admin/admin_register_coach_view.dart';
import 'package:gdg_app/views/admin/admin_register_player_view.dart';
import 'package:gdg_app/views/admin/admin_view_coaches.dart';
import 'package:gdg_app/views/admin/admin_view_players.dart';
import 'package:gdg_app/views/admin/admin_view_request_sponsors.dart';
import 'package:gdg_app/views/coach/coach_mark_session.dart';
import 'package:gdg_app/views/coach/coach_view_coaching_staffs_assigned.dart';
import 'package:gdg_app/views/coach/coach_view_player_report.dart';
import 'package:gdg_app/views/gym_trainer/gym_trainer_home_view.dart';
import 'package:gdg_app/views/gym_trainer/gym_trainer_make_An_announcement.dart';
import 'package:gdg_app/views/gym_trainer/gym_trainer_mark_session_view.dart';
import 'package:gdg_app/views/gym_trainer/gym_trainer_profile.dart';
import 'package:gdg_app/views/gym_trainer/gym_trainer_update_gym_plan_view.dart';
import 'package:gdg_app/views/gym_trainer/gym_trainer_view_player_medical_report.dart';
import 'package:gdg_app/views/individual/individual_achievement_view.dart';
import 'package:gdg_app/views/individual/individual_contact_sponsor_view.dart';
import 'package:gdg_app/views/individual/individual_daily_diet_view.dart';
import 'package:gdg_app/views/individual/individual_finances_view.dart';
import 'package:gdg_app/views/individual/individual_game_view.dart';
import 'package:gdg_app/views/individual/individual_gym_plan_view.dart';
import 'package:gdg_app/views/individual/individual_home_view.dart';
import 'package:gdg_app/views/medical_staff/medical_staff_home_page.dart';
import 'package:gdg_app/views/medical_staff/medical_staff_make_an_announcement_view.dart';
import 'package:gdg_app/views/medical_staff/medical_staff_mark_session.dart';
import 'package:gdg_app/views/medical_staff/medical_staff_profile.dart';
import 'package:gdg_app/views/medical_staff/medical_staff_put_records.dart';
import 'package:gdg_app/views/medical_staff/medical_staff_view_player_medical_report.dart';
import 'package:gdg_app/views/player/calendar_view.dart';
import 'package:gdg_app/views/coach/coach_home_page.dart';
import 'package:gdg_app/views/coach/coach_make_an_announcement.dart';
import 'package:gdg_app/views/coach/coach_profile.dart';
import 'package:gdg_app/views/player/fill_injury_form_view.dart';
import 'package:gdg_app/views/player/medical_report_view.dart';
import 'package:gdg_app/views/player/player_financial_view.dart';
import 'package:gdg_app/views/player/player_home.dart';
import 'package:gdg_app/views/player/players_view_announcement.dart';
import 'package:gdg_app/views/sponsor/find_profile_view.dart';
import 'package:gdg_app/views/individual_register_view.dart';
import 'package:gdg_app/views/sponsor/invitation_view.dart';
import 'package:gdg_app/views/landing_page_view.dart';
import 'package:gdg_app/views/login_view.dart';
import 'package:gdg_app/views/organization_registration.dart';
import 'package:gdg_app/views/player/player_nutrition_view.dart';
import 'package:gdg_app/views/sponsor/request_view.dart';
import 'package:gdg_app/views/sponsor/sponsor_home_view.dart';
import 'package:gdg_app/views/sponsor/sports_of_interest_view.dart';
import 'package:gdg_app/views/player/view_coach.dart';
import 'package:gdg_app/views/player/view_gym_plan.dart';
import 'package:gdg_app/views/player/view_player_statistics.dart';
import 'package:gdg_app/views/admin/video_analysis_view.dart';
import 'package:gdg_app/views/sponsor_register_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const LandingPageView(),
    debugShowCheckedModeBanner: false,
    onGenerateRoute: (settings) {
      if (settings.name == loginRoute) {
        final args = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) {
            return LoginView(sourcePage: args);
          },
        );
      }
      return null;
    },
    routes: {
      individualRegisterRoute: (context) => const IndividualRegisterView(),
      landingPageRoute: (context) => const LandingPageView(),
      coachHomeRoute: (context) => const CoachHomePage(),
      coachMakeAnAnnouncementRoute: (context) => const CoachMakeAnAnnouncement(),
      coachProfileRoute: (context) => const CoachProfile(),
      coachAdminPlayerRoute: (context) => const AdminPlayerCoachOption(),
      organizationRegistrationViewRoute: (context) => const OrganizationRegistrationView(),
      sponsorHomeViewRoute: (context) => const SponsorHomeView(),
      sportsOfInterestRoute: (context) => const SportsOfInterestView(),
      invitationToSponsorRoute: (context) => const InvitationsView(),
      requestToSponsorPageRoute: (context) => const RequestsView(),
      findOrganizationOrPlayersRoute: (context) => const FindProfilesView(),
      playerHomeRoute: (context) => const PlayerHome(),
      viewCoachProfileRoute: (context) => const ViewCoach(),
      viewPlayerStatisticsRoute: (context) => const ViewPlayerStatistics(),
      medicalReportRoute: (context) => const MedicalReport(),
      nutritionalPlanRoute: (context) => const NutritionPlan(),
      playerviewAnnouncementRoute: (context) => const ViewAnnouncements(),
      viewCalendarRoute: (context) => const CalendarView(),
      viewGymPlanRoute: (context) => const ViewGymPlan(),
      fillInjuryFormRoute: (context) => const FillInjuryFormView(),
      adminHomeRoute: (context) => const AdminHomeView(),
      registerAdminRoute: (context) => const AdminRegisterAdminView(),
      registerCoachRoute: (context) => const AdminRegisterCoachView(),
      registerPlayerRoute: (context) => const AdminRegisterPlayerView(),
      viewAllPlayersRoute: (context) => const AdminViewPlayers(),
      viewAllCoachesRoute: (context) => const AdminViewCoaches(),
      requestViewSponsorsRoute: (context) => const AdminViewRequestSponsors(),
      videoAnalysisRoute: (context) => const VideoAnalysisView(),
      editFormsRoute: (context) => const AdminAccessForm(),
      individualHomeRoute: (context) => const IndividualHomeView(),
      uploadAchievementRoute: (context) => const IndividualAchievementView(),
      gameVideosRoute: (context) => const IndividualGameView(),
      viewContactSponsorRoute: (context) => const IndividualContactSponsorView(),
      individualDailyDietRoute: (context) => const IndividualDailyDietView(),
      individualGymPlanRoute: (context) => const IndividualGymPlanView(),
      individualFinancesRoute: (context) => const IndividualFinances(),
      playerFinancialViewRoute: (context) => const PlayerFinancialView(),
      adminManagePlayerFinancesRoute: (context) => const AdminFinancialView(),
      coachMarkSessionRoute: (context) => const CoachMarkSession(),
      coachViewPlayerMedicalReportRoute: (context) => const CoachViewPlayerReport(),
      viewCoachingStaffsAssignedRoute: (context) => const CoachViewCoachingStaffsAssigned(),
      sponsorRegisterViewRoute: (context) => const SponsorRegisterView(),
      medicalStaffHomeRoute: (context) => const MedicalStaffHomePage(),
      medicalStaffUpdateMedicalReportRoute: (context) => const MedicalStaffPutRecords(),
      medicalStaffMakeAnAnnouncementRoute: (context) => const MedicalStaffMakeAnAnnouncement(),
      medicalStaffMarkSessionRoute: (context) => const MedicalStaffMarkSession(),
      medicalStaffViewPlayerMedicalReportRoute: (context) => const MedicalStaffPlayerReport(),
      trainerHomeRoute: (context) => const TrainerHomePage(),
      trainerMakeAnAnnouncementRoute: (context) => const GymTrainerMakeAnAnnouncement(),
      trainerMarkSessionRoute: (context) => const TrainerMarkSession(),
      trainerUpdateGymPlanRoute: (context) => const GymTrainerUpdateGymPlanView(),
      trainerViewPlayerMedicalReportRoute: (context) => const TrainerPlayerReport(),
      medicalStaffProfileRoute: (context) => const MedicalStaffProfile(),
      trainerProfileRoute: (context) => const GymTrainerProfile(),
    },
  ));
}