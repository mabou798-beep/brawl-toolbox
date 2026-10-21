import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/ads/interstitial_ad_manager.dart';
import '../../core/theme/app_theme.dart';
import '../../models/brawler.dart';
import '../../providers/brawlers_provider.dart';
import '../../widgets/fallback_image.dart';
import '../../widgets/state_views.dart';

class _Question {
  final Brawler answer;
  final List<Brawler> options;
  final bool isSilhouette;

  _Question({
    required this.answer,
    required this.options,
    required this.isSilhouette,
  });
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Random _random = Random();
  final List<_Question> _questions = [];
  int _current = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _built = false;

  void _buildQuiz(List<Brawler> brawlers) {
    if (_built || brawlers.length < 4) return;
    _built = true;
    final pool = List<Brawler>.from(brawlers)..shuffle(_random);
    final count = min(10, pool.length);
    for (var i = 0; i < count; i++) {
      final answer = pool[i];
      final distractors = (List<Brawler>.from(brawlers)..shuffle(_random))
          .where((b) => b.id != answer.id)
          .take(3)
          .toList();
      final options = [answer, ...distractors]..shuffle(_random);
      _questions.add(
        _Question(
          answer: answer,
          options: options,
          isSilhouette: i % 3 != 0,
        ),
      );
    }
  }

  void _selectAnswer(int index, Brawler option) {
    if (_answered) return;
    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (option.id == _questions[_current].answer.id) _score++;
    });
  }

  void _next() {
    final wasLastQuestion = _current + 1 == _questions.length;
    setState(() {
      _current++;
      _selectedIndex = null;
      _answered = false;
    });
    // Natural break point: the round just ended and results are showing,
    // rather than interrupting mid-question.
    if (wasLastQuestion) InterstitialAdManager.instance.showIfAvailable();
  }

  void _restart() {
    setState(() {
      _current = 0;
      _score = 0;
      _selectedIndex = null;
      _answered = false;
      _questions.clear();
      _built = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrawlersProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Guess the Brawler')),
      body: SafeArea(child: _buildBody(provider)),
    );
  }

  Widget _buildBody(BrawlersProvider provider) {
    if (provider.status == LoadStatus.loading || provider.status == LoadStatus.idle) {
      return const LoadingView(message: 'Loading brawlers...');
    }
    if (provider.status == LoadStatus.error) {
      return ErrorView(
        message: provider.errorMessage ?? 'Unknown error',
        onRetry: () => provider.load(),
      );
    }

    _buildQuiz(provider.brawlers);

    if (_questions.isEmpty) {
      return const Center(child: Text('Not enough data to build a quiz.'));
    }

    if (_current >= _questions.length) {
      return _ResultView(score: _score, total: _questions.length, onRestart: _restart);
    }

    final question = _questions[_current];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_current + 1} / ${_questions.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Score: $_score',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_current) / _questions.length,
              minHeight: 6,
              backgroundColor: AppColors.surfaceAlt,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: Container(
                width: 215,
                height: 260,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(10),
                child: _QuizArt(
                  key: ValueKey(question.answer.id),
                  brawler: question.answer,
                  silhouette: question.isSilhouette && !_answered,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Who is this brawler?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...List.generate(question.options.length, (i) {
            final option = question.options[i];
            final isCorrect = option.id == question.answer.id;
            Color? tileColor;
            if (_answered) {
              if (isCorrect) {
                tileColor = AppColors.accentGreen.withValues(alpha: 0.25);
              } else if (i == _selectedIndex) {
                tileColor = AppColors.accentPink.withValues(alpha: 0.25);
              }
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: tileColor ?? AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _selectAnswer(i, option),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (_answered && isCorrect)
                          const FaIcon(FontAwesomeIcons.circleCheck, color: AppColors.accentGreen, size: 18),
                        if (_answered && !isCorrect && i == _selectedIndex)
                          const FaIcon(FontAwesomeIcons.circleXmark, color: AppColors.accentPink, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          if (_answered)
            FilledButton(
              onPressed: _next,
              child: Text(_current + 1 == _questions.length ? 'See Results' : 'Next Question'),
            ),
        ],
      ),
    );
  }
}

/// The artwork for one question.
///
/// A silhouette is only possible from the full-body model render: it is the
/// one image on the CDN with a transparent background, so painting it black
/// leaves the brawler's outline. The square portraits are opaque, and
/// blacking one out produces a black square and an unanswerable question.
/// The CDN has no model render for the newest few brawlers, so if it fails to
/// load the question quietly becomes a normal one rather than a blank box.
class _QuizArt extends StatefulWidget {
  final Brawler brawler;
  final bool silhouette;

  const _QuizArt({super.key, required this.brawler, required this.silhouette});

  @override
  State<_QuizArt> createState() => _QuizArtState();
}

class _QuizArtState extends State<_QuizArt> {
  bool _noModelArt = false;

  void _markMissing() {
    // errorWidget runs during build, so the state change waits for the frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_noModelArt) setState(() => _noModelArt = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.silhouette && !_noModelArt) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
        child: CachedNetworkImage(
          imageUrl: widget.brawler.wallpaperUrl,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          placeholder: (_, _) => const SizedBox.shrink(),
          errorWidget: (_, _, _) {
            _markMissing();
            return const SizedBox.shrink();
          },
        ),
      );
    }

    return FallbackImage(
      candidates: widget.brawler.artCandidates,
      fit: BoxFit.contain,
      // Never the brawler's initial here — that would hand over the answer.
      fallback: const Center(
        child: FaIcon(
          FontAwesomeIcons.question,
          size: 44,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onRestart;

  const _ResultView({required this.score, required this.total, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : (score / total * 100).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(FontAwesomeIcons.trophy, color: AppColors.primary, size: 56),
            const SizedBox(height: 16),
            Text('$score / $total', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(
              '$pct% correct',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRestart,
              icon: const FaIcon(FontAwesomeIcons.arrowRotateRight, size: 16),
              label: const Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}
