import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/responsive.dart';

/// Privacy policy + Terms hub. Two tabs of static text — required by Play
/// Store / App Store and useful as a transparent reference for users.
class LegalScreen extends StatelessWidget {
  /// 0 = Privacy, 1 = Terms.
  final int initialTab;
  const LegalScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Privacy & Terms'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Privacy policy'),
              Tab(text: 'Terms of use'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MaxContentWidth(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  _LegalHeader(
                    title: 'Privacy policy',
                    subtitle: 'Last updated: Today',
                  ),
                  _LegalSection(
                    title: 'Summary in plain English',
                    body:
                        'PipeSmart is designed to work offline as a training and field reference tool. It does not collect any personal data on its own. The only data leaving your device is what you explicitly send when you use the optional AI tutor or photo-diagnosis features, and that goes directly to Anthropic\'s API — not to us.',
                  ),
                  _LegalSection(
                    title: 'What is stored on your device',
                    body:
                        'Your role and goals from onboarding, your bookmarks, your quiz scores, your checklist progress, your TTS voice preferences, and (if you set one) your Anthropic API key — all stored locally using shared_preferences. None of this is uploaded anywhere.',
                  ),
                  _LegalSection(
                    title: 'What we send to Anthropic when you use AI features',
                    body:
                        'When you use the AI tutor chat or photo fault diagnosis, your typed question, the chat history of that session, and any image you choose to attach are sent over HTTPS to api.anthropic.com using your API key. The image is base64-encoded and sent within the request body. Anthropic processes the request under its own privacy policy at https://www.anthropic.com/privacy. We never see this data — it goes directly from your device to Anthropic.',
                  ),
                  _LegalSection(
                    title: 'Anthropic API key',
                    body:
                        'If you provide your own Anthropic API key, it is saved on this device only. We never transmit it to any of our servers. If a build of this app was distributed with a built-in demo key, the warning panel in the AI tutor settings explains the implications. You can clear the saved key at any time from Settings.',
                  ),
                  _LegalSection(
                    title: 'Camera and photos',
                    body:
                        'The photo fault diagnosis feature requests camera or photo-library permission. Images you select are processed in memory and sent to Anthropic for analysis only when you tap Analyse. They are not saved by the app or uploaded anywhere else.',
                  ),
                  _LegalSection(
                    title: 'Microphone and text-to-speech',
                    body:
                        'The narration uses your device\'s built-in text-to-speech engine. No audio is recorded; the app only speaks. The microphone is not used.',
                  ),
                  _LegalSection(
                    title: 'Analytics and tracking',
                    body:
                        'This app does not include any third-party analytics, advertising or tracking SDKs. It does not collect crash reports automatically.',
                  ),
                  _LegalSection(
                    title: 'Children',
                    body:
                        'The app is intended for working plumbers and apprentices aged 16 and over. It is not directed at children under 13 and does not knowingly collect any data from them.',
                  ),
                  _LegalSection(
                    title: 'Your choices',
                    body:
                        'You can clear your saved data at any time by uninstalling the app or by clearing the app\'s storage from your device settings. You can revoke camera or photo permission from the operating system settings.',
                  ),
                  _LegalSection(
                    title: 'Contact',
                    body:
                        'For privacy questions or data requests, contact the app publisher via the support email shown on the Play Store / App Store listing.',
                  ),
                ],
              ),
            ),
            MaxContentWidth(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  _LegalHeader(
                    title: 'Terms of use',
                    subtitle: 'Last updated: Today',
                  ),
                  _LegalSection(
                    title: 'About this app',
                    body:
                        'PipeSmart is a study and field reference tool for UK plumbers and apprentices. It is not a substitute for formal training, qualification, manufacturer instructions or the relevant standards and regulations.',
                  ),
                  _LegalSection(
                    title: 'Not professional advice',
                    body:
                        'Content in this app — including lessons, calculators, simulations and AI-generated answers — is provided for educational reference only. You must always verify any figure, procedure or regulatory requirement against the current manufacturer documentation, the British Standards or the Approved Codes of Practice that apply to your job. The publisher accepts no liability for any work undertaken in reliance on this app.',
                  ),
                  _LegalSection(
                    title: 'Restricted work',
                    body:
                        'Gas work in the UK is restricted to Gas Safe registered engineers. Electrical work in dwellings may be notifiable under Building Regulations Part P. Unvented hot water work over 15 litres is notifiable. Refrigerant circuit work requires F-gas Category I competence. Medical gas pipeline work requires AP-MGPS oversight. By using this app you acknowledge these constraints and agree to operate only within your own competence and registration.',
                  ),
                  _LegalSection(
                    title: 'AI-generated content',
                    body:
                        'The AI tutor and photo diagnosis features call the Anthropic Claude API. AI responses are generated automatically and may contain errors, omissions, or out-of-date information. You must not rely on AI output as the basis for any safety-critical decision.',
                  ),
                  _LegalSection(
                    title: 'API key responsibility',
                    body:
                        'If you supply your own Anthropic API key, you are responsible for the costs incurred against your account, for keeping that key secure, and for revoking it if it is compromised. The publisher is not responsible for any charges or misuse arising from your key.',
                  ),
                  _LegalSection(
                    title: 'Acceptable use',
                    body:
                        'You agree not to use the app to perform any activity that breaches UK law or the Acceptable Use Policy of the Anthropic API. You agree not to upload images containing personal data of others without permission.',
                  ),
                  _LegalSection(
                    title: 'Intellectual property',
                    body:
                        'The app and its content are protected by copyright. You may use the app for your own training and field reference. You may not copy or redistribute the lessons, simulations or other content commercially without written permission.',
                  ),
                  _LegalSection(
                    title: 'Liability',
                    body:
                        'To the fullest extent permitted by UK law, the publisher excludes all liability for indirect or consequential loss arising from your use of this app. Nothing in these terms limits liability for death or personal injury caused by negligence, or for fraud.',
                  ),
                  _LegalSection(
                    title: 'Changes',
                    body:
                        'These terms may be updated as the app evolves. Continued use after a notified update constitutes acceptance.',
                  ),
                  _LegalSection(
                    title: 'Governing law',
                    body:
                        'These terms are governed by the laws of England and Wales. Disputes will be heard in the courts of England and Wales.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _LegalHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  final String title;
  final String body;
  const _LegalSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(body, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
