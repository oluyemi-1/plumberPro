// L8 / HSG 274 Legionella risk assessment data.
//
// Structured risk-scored questionnaire used by the L8 risk screen.
// Higher scores indicate higher Legionella risk.

class L8RiskOption {
  final String label;
  final int score;
  final String guidance;

  const L8RiskOption({
    required this.label,
    required this.score,
    required this.guidance,
  });

  String get speakable => '$label. Score $score. $guidance';
}

class L8RiskQuestion {
  final String question;
  final List<L8RiskOption> options;

  const L8RiskQuestion({
    required this.question,
    required this.options,
  });
}

class L8RiskCategory {
  final String name;
  final List<L8RiskQuestion> questions;

  const L8RiskCategory({
    required this.name,
    required this.questions,
  });
}

const l8Categories = <L8RiskCategory>[
  L8RiskCategory(
    name: 'Water temperatures',
    questions: [
      L8RiskQuestion(
        question: 'Cold water storage temperature at the tank',
        options: [
          L8RiskOption(
            label: 'Below 20 C all year',
            score: 0,
            guidance: 'Compliant with L8. Legionella growth suppressed below 20 C.',
          ),
          L8RiskOption(
            label: '20 to 22 C in summer only',
            score: 2,
            guidance: 'Marginal. Insulate tanks and inlet pipework; review tank location.',
          ),
          L8RiskOption(
            label: 'Frequently above 22 C',
            score: 4,
            guidance: 'High risk. Bacteria multiply rapidly between 20 and 45 C. Investigate heat gain immediately.',
          ),
        ],
      ),
      L8RiskQuestion(
        question: 'Hot water storage (calorifier) temperature',
        options: [
          L8RiskOption(
            label: 'At or above 60 C, returning at 50 C+',
            score: 0,
            guidance: 'Pasteurisation temperature met. Confirms HSG 274 part 2 guidance.',
          ),
          L8RiskOption(
            label: '55 to 59 C',
            score: 2,
            guidance: 'Below recommended 60 C. Raise thermostat and verify with calibrated probe.',
          ),
          L8RiskOption(
            label: 'Below 55 C',
            score: 4,
            guidance: 'Non-compliant. Legionella will proliferate. Service or replace storage heater.',
          ),
        ],
      ),
      L8RiskQuestion(
        question: 'Distribution: hot water at sentinel taps within one minute',
        options: [
          L8RiskOption(
            label: '50 C or above at all sentinels',
            score: 0,
            guidance: 'Distribution losses acceptable.',
          ),
          L8RiskOption(
            label: '45 to 49 C',
            score: 2,
            guidance: 'Borderline. Check insulation on dead legs and circulation pump operation.',
          ),
          L8RiskOption(
            label: 'Below 45 C',
            score: 4,
            guidance: 'Severe distribution issue. Re-balance the secondary return and lag exposed pipework.',
          ),
        ],
      ),
      L8RiskQuestion(
        question: 'TMV servicing and monthly verification',
        options: [
          L8RiskOption(
            label: 'Documented monthly checks and annual service',
            score: 0,
            guidance: 'Meets HSG 274 part 2 maintenance frequency.',
          ),
          L8RiskOption(
            label: 'Annual service only',
            score: 2,
            guidance: 'Add monthly outlet temperature checks to schedule.',
          ),
          L8RiskOption(
            label: 'No formal TMV regime',
            score: 4,
            guidance: 'Significant risk of mixed tepid water at outlets. Implement immediately.',
          ),
        ],
      ),
    ],
  ),
  L8RiskCategory(
    name: 'System cleanliness',
    questions: [
      L8RiskQuestion(
        question: 'Sediment build-up in cold water storage tanks',
        options: [
          L8RiskOption(
            label: 'Tanks inspected and clean',
            score: 0,
            guidance: 'Annual inspection regime functioning.',
          ),
          L8RiskOption(
            label: 'Light sediment present',
            score: 2,
            guidance: 'Schedule a clean and chlorination at 50 ppm for one hour.',
          ),
          L8RiskOption(
            label: 'Heavy sediment or biofilm',
            score: 4,
            guidance: 'Tank requires immediate disinfection per BS 8558 / L8 guidance.',
          ),
        ],
      ),
      L8RiskQuestion(
        question: 'Scale and corrosion in calorifier',
        options: [
          L8RiskOption(
            label: 'Drained and inspected within 12 months, clean',
            score: 0,
            guidance: 'Routine drain-down evidenced.',
          ),
          L8RiskOption(
            label: 'Scale visible at sight glass or drain',
            score: 3,
            guidance: 'Scale insulates the heater base; descale and consider water softener.',
          ),
          L8RiskOption(
            label: 'Never inspected',
            score: 4,
            guidance: 'L8 requires annual inspection of stored hot water vessels.',
          ),
        ],
      ),
      L8RiskQuestion(
        question: 'Dead legs and redundant pipework',
        options: [
          L8RiskOption(
            label: 'None present, system audited',
            score: 0,
            guidance: 'Pipework as-fitted matches current usage.',
          ),
          L8RiskOption(
            label: 'Some short blind ends (under 2 D)',
            score: 2,
            guidance: 'Acceptable but log on schematic.',
          ),
          L8RiskOption(
            label: 'Long redundant branches present',
            score: 4,
            guidance: 'Cap back to the main as close to the through-flow as possible.',
          ),
        ],
      ),
      L8RiskQuestion(
        question: 'Strainers, filters and flexible hoses',
        options: [
          L8RiskOption(
            label: 'Cleaned to manufacturer schedule',
            score: 0,
            guidance: 'Documented cleaning regime in place.',
          ),
          L8RiskOption(
            label: 'EPDM hoses, no inspection record',
            score: 3,
            guidance: 'EPDM supports biofilm. Replace with WRAS-listed PEX braided hose.',
          ),
        ],
      ),
    ],
  ),
  L8RiskCategory(
    name: 'Materials and design',
    questions: [
      L8RiskQuestion(
        question: 'Pipe and fitting materials',
        options: [
          L8RiskOption(
            label: 'WRAS-approved throughout',
            score: 0,
            guidance: 'Materials compliant with the Water Fittings Regulations.',
          ),
          L8RiskOption(
            label: 'Mixed, mostly approved',
            score: 2,
            guidance: 'Audit and replace any non-listed components at next planned works.',
          ),
          L8RiskOption(
            label: 'Lead pipework still in use',
            score: 4,
            guidance: 'Replace lead service immediately. Lead is a Cat 5 hazard.',
          ),
        ],
      ),
      L8RiskQuestion(
        question: 'Underused fittings on the system',
        options: [
          L8RiskOption(
            label: 'All outlets used at least weekly',
            score: 0,
            guidance: 'Turnover of water adequate.',
          ),
          L8RiskOption(
            label: 'Some seasonal outlets',
            score: 2,
            guidance: 'Add to weekly flushing log.',
          ),
          L8RiskOption(
            label: 'Outlets dormant for over a month',
            score: 4,
            guidance: 'Either remove or commission a flushing routine immediately.',
          ),
        ],
      ),
      L8RiskQuestion(
        question: 'Insulation continuity',
        options: [
          L8RiskOption(
            label: 'Continuous on hot and cold mains',
            score: 0,
            guidance: 'Heat gain on cold and loss on hot minimised.',
          ),
          L8RiskOption(
            label: 'Gaps at valves and supports',
            score: 2,
            guidance: 'Refit pre-formed lagging shells.',
          ),
          L8RiskOption(
            label: 'Bare runs over 2 m',
            score: 3,
            guidance: 'Significant heat exchange; insulate to BS 5422.',
          ),
        ],
      ),
    ],
  ),
  L8RiskCategory(
    name: 'Storage',
    questions: [
      L8RiskQuestion(
        question: 'Cold water storage tank lid',
        options: [
          L8RiskOption(
            label: 'Tight, insect-proof, gasketed',
            score: 0,
            guidance: 'Conforms to BS EN 806 and the Water Fittings Regulations.',
          ),
          L8RiskOption(
            label: 'Lid present but not sealed',
            score: 2,
            guidance: 'Replace gasket; vermin ingress is a Cat 5 contamination route.',
          ),
          L8RiskOption(
            label: 'Lid missing or warped',
            score: 4,
            guidance: 'Tank fails Regulation 16; replace immediately.',
          ),
        ],
      ),
      L8RiskQuestion(
        question: 'Tank insulation',
        options: [
          L8RiskOption(
            label: 'Fully insulated jacket fitted',
            score: 0,
            guidance: 'Maintains stored water below 20 C.',
          ),
          L8RiskOption(
            label: 'Partial insulation',
            score: 2,
            guidance: 'Top up insulation, especially on the lid.',
          ),
          L8RiskOption(
            label: 'No insulation',
            score: 3,
            guidance: 'Heat gain likely in summer; insulate to BS 5422.',
          ),
        ],
      ),
      L8RiskQuestion(
        question: 'Screened overflow and warning pipe',
        options: [
          L8RiskOption(
            label: 'Both screened and discharge visible',
            score: 0,
            guidance: 'Compliant with the Water Fittings Regulations Schedule 2.',
          ),
          L8RiskOption(
            label: 'Screen damaged',
            score: 3,
            guidance: 'Replace stainless mesh; insect ingress causes biofouling.',
          ),
          L8RiskOption(
            label: 'No screen or discharge into hidden void',
            score: 4,
            guidance: 'Route warning pipe to a visible position and fit screen.',
          ),
        ],
      ),
      L8RiskQuestion(
        question: 'Monthly visual inspection record',
        options: [
          L8RiskOption(
            label: 'Documented and signed off',
            score: 0,
            guidance: 'Demonstrates duty-holder oversight.',
          ),
          L8RiskOption(
            label: 'Ad-hoc, no log',
            score: 2,
            guidance: 'Adopt a written log book per L8.',
          ),
          L8RiskOption(
            label: 'Never inspected',
            score: 4,
            guidance: 'Failure to demonstrate any control measure.',
          ),
        ],
      ),
    ],
  ),
  L8RiskCategory(
    name: 'Showers and outlets',
    questions: [
      L8RiskQuestion(
        question: 'Shower head descale frequency',
        options: [
          L8RiskOption(
            label: 'Quarterly descale and disinfect',
            score: 0,
            guidance: 'HSG 274 part 2 frequency met.',
          ),
          L8RiskOption(
            label: 'Annual',
            score: 2,
            guidance: 'Increase frequency in hard water areas.',
          ),
          L8RiskOption(
            label: 'Never',
            score: 4,
            guidance: 'Aerosol-generating outlet. Immediate descale required.',
          ),
        ],
      ),
      L8RiskQuestion(
        question: 'Weekly flushing of low-use outlets',
        options: [
          L8RiskOption(
            label: 'Logged weekly run for 2 minutes',
            score: 0,
            guidance: 'Maintains turnover; meets L8 control measure.',
          ),
          L8RiskOption(
            label: 'Occasional flushing',
            score: 2,
            guidance: 'Implement a written rota.',
          ),
          L8RiskOption(
            label: 'Not flushed',
            score: 4,
            guidance: 'Outlet is effectively a stagnation point.',
          ),
        ],
      ),
      L8RiskQuestion(
        question: 'Spray taps and aerators',
        options: [
          L8RiskOption(
            label: 'Cleaned to schedule',
            score: 0,
            guidance: 'Aerator cleaning logged.',
          ),
          L8RiskOption(
            label: 'No record',
            score: 3,
            guidance: 'Aerators trap debris; clean and disinfect quarterly.',
          ),
        ],
      ),
    ],
  ),
  L8RiskCategory(
    name: 'Records and roles',
    questions: [
      L8RiskQuestion(
        question: 'Written scheme of control',
        options: [
          L8RiskOption(
            label: 'In place, reviewed annually',
            score: 0,
            guidance: 'Required by L8 paragraph 49.',
          ),
          L8RiskOption(
            label: 'Out of date (over 2 years)',
            score: 3,
            guidance: 'Review and re-issue.',
          ),
          L8RiskOption(
            label: 'No written scheme',
            score: 4,
            guidance: 'Statutory non-compliance.',
          ),
        ],
      ),
      L8RiskQuestion(
        question: 'Named responsible person',
        options: [
          L8RiskOption(
            label: 'Appointed in writing and trained',
            score: 0,
            guidance: 'Duty-holder requirement satisfied.',
          ),
          L8RiskOption(
            label: 'Appointed but no training record',
            score: 2,
            guidance: 'Schedule City and Guilds or equivalent training.',
          ),
          L8RiskOption(
            label: 'No appointment',
            score: 4,
            guidance: 'L8 paragraph 36 not met.',
          ),
        ],
      ),
      L8RiskQuestion(
        question: 'Training of operatives',
        options: [
          L8RiskOption(
            label: 'Refreshed within 2 years',
            score: 0,
            guidance: 'Competence demonstrable.',
          ),
          L8RiskOption(
            label: 'Older than 2 years',
            score: 2,
            guidance: 'Plan refresher.',
          ),
          L8RiskOption(
            label: 'No record',
            score: 4,
            guidance: 'Cannot demonstrate competence.',
          ),
        ],
      ),
      L8RiskQuestion(
        question: 'Log book of monitoring results',
        options: [
          L8RiskOption(
            label: 'Up to date and counter-signed',
            score: 0,
            guidance: 'Best practice.',
          ),
          L8RiskOption(
            label: 'Sporadic entries',
            score: 2,
            guidance: 'Define minimum data set per HSG 274.',
          ),
          L8RiskOption(
            label: 'No log book',
            score: 4,
            guidance: 'Fundamental failure of the control regime.',
          ),
        ],
      ),
    ],
  ),
];
