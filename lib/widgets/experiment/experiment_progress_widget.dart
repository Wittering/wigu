import 'package:flutter/material.dart';
import '../../models/career_experiment.dart';
import '../../utils/theme.dart';

/// Widget for tracking and updating experiment progress
/// Provides interactive controls for milestone tracking and note-taking
class ExperimentProgressWidget extends StatefulWidget {
  final CareerExperiment experiment;
  final double progressPercentage;
  final List<String> milestonesCompleted;
  final List<String> notes;
  final Function(double progress, List<String> milestones, List<String> notes)? onProgressUpdate;
  final bool isEditable;

  const ExperimentProgressWidget({
    Key? key,
    required this.experiment,
    required this.progressPercentage,
    this.milestonesCompleted = const [],
    this.notes = const [],
    this.onProgressUpdate,
    this.isEditable = true,
  }) : super(key: key);

  @override
  State<ExperimentProgressWidget> createState() => _ExperimentProgressWidgetState();
}

class _ExperimentProgressWidgetState extends State<ExperimentProgressWidget> {
  late double _currentProgress;
  late List<String> _completedMilestones;
  late List<String> _currentNotes;
  final TextEditingController _noteController = TextEditingController();
  bool _isAddingNote = false;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.progressPercentage;
    _completedMilestones = List.from(widget.milestonesCompleted);
    _currentNotes = List.from(widget.notes);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 16),
            _buildProgressSection(theme),
            const SizedBox(height: 16),
            _buildMilestonesSection(theme),
            const SizedBox(height: 16),
            _buildNotesSection(theme),
            if (widget.isEditable) ...[
              const SizedBox(height: 16),
              _buildUpdateButton(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.track_changes,
          color: AppTheme.accentTeal,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress Tracking',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Track your progress and learnings',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedText,
                ),
              ),
            ],
          ),
        ),
        if (widget.experiment.startedAt != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.mutedTone2.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Day ${widget.experiment.daysSinceStarted ?? 0}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Progress',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(_currentProgress * 100).round()}%',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppTheme.accentTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Progress bar
        LinearProgressIndicator(
          value: _currentProgress,
          backgroundColor: AppTheme.mutedTone2.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(
            _getProgressColor(_currentProgress),
          ),
        ),
        
        if (widget.isEditable) ...[
          const SizedBox(height: 12),
          Slider(
            value: _currentProgress,
            onChanged: (value) {
              setState(() {
                _currentProgress = value;
              });
            },
            activeColor: AppTheme.accentTeal,
            inactiveColor: AppTheme.mutedTone2,
            divisions: 20,
            label: '${(_currentProgress * 100).round()}%',
          ),
        ],
        
        // Time tracking
        if (widget.experiment.startedAt != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: AppTheme.mutedText,
              ),
              const SizedBox(width: 6),
              Text(
                _getTimeTrackingText(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedText,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMilestonesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Success Criteria',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        if (widget.experiment.successCriteria.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.mutedTone1.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No specific success criteria defined for this experiment.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.mutedText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ] else ...[
          ...widget.experiment.successCriteria.map((criterion) {
            final isCompleted = _completedMilestones.contains(criterion);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: widget.isEditable ? () => _toggleMilestone(criterion) : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCompleted 
                      ? AppTheme.successGreen.withOpacity(0.1)
                      : AppTheme.mutedTone1.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCompleted 
                        ? AppTheme.successGreen.withOpacity(0.3)
                        : AppTheme.mutedTone2.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isCompleted ? AppTheme.successGreen : AppTheme.mutedText,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          criterion,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isCompleted ? AppTheme.successGreen : AppTheme.secondaryText,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          
          // Progress summary
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.assessment,
                  color: AppTheme.accentTeal,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Completed ${_completedMilestones.length} of ${widget.experiment.successCriteria.length} criteria',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress Notes',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.isEditable)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isAddingNote = true;
                  });
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Note'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accentTeal,
                  minimumSize: const Size(80, 32),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (_isAddingNote) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.accentTeal),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Add a progress note, insight, or reflection...',
                    border: InputBorder.none,
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isAddingNote = false;
                          _noteController.clear();
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addNote,
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        if (_currentNotes.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.mutedTone1.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.note_outlined,
                  color: AppTheme.mutedText,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'No progress notes yet. Add notes to track insights and learnings.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          ..._currentNotes.asMap().entries.map((entry) {
            final index = entry.key;
            final note = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.mutedTone1.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      note,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  if (widget.isEditable)
                    IconButton(
                      onPressed: () => _removeNote(index),
                      icon: const Icon(Icons.close),
                      iconSize: 16,
                      color: AppTheme.mutedText,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildUpdateButton(ThemeData theme) {
    final hasChanges = _currentProgress != widget.progressPercentage ||
        !_listsEqual(_completedMilestones, widget.milestonesCompleted) ||
        !_listsEqual(_currentNotes, widget.notes);
    
    if (!hasChanges) return const SizedBox.shrink();
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _updateProgress,
        icon: const Icon(Icons.save),
        label: const Text('Update Progress'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  void _toggleMilestone(String milestone) {
    setState(() {
      if (_completedMilestones.contains(milestone)) {
        _completedMilestones.remove(milestone);
      } else {
        _completedMilestones.add(milestone);
      }
      
      // Auto-update progress based on milestone completion
      final totalCriteria = widget.experiment.successCriteria.length;
      if (totalCriteria > 0) {
        final completionRatio = _completedMilestones.length / totalCriteria;
        _currentProgress = (_currentProgress * 0.7) + (completionRatio * 0.3);
        _currentProgress = _currentProgress.clamp(0.0, 1.0);
      }
    });
  }

  void _addNote() {
    if (_noteController.text.trim().isNotEmpty) {
      setState(() {
        _currentNotes.add(_noteController.text.trim());
        _noteController.clear();
        _isAddingNote = false;
      });
    }
  }

  void _removeNote(int index) {
    setState(() {
      _currentNotes.removeAt(index);
    });
  }

  void _updateProgress() {
    widget.onProgressUpdate?.call(
      _currentProgress,
      _completedMilestones,
      _currentNotes,
    );
  }

  String _getTimeTrackingText() {
    final daysSinceStarted = widget.experiment.daysSinceStarted ?? 0;
    final estimatedDays = widget.experiment.estimatedDurationDays;
    final daysRemaining = estimatedDays - daysSinceStarted;
    
    if (daysRemaining > 0) {
      return 'Day $daysSinceStarted of $estimatedDays • $daysRemaining days remaining';
    } else if (daysRemaining == 0) {
      return 'Day $daysSinceStarted of $estimatedDays • Due today';
    } else {
      return 'Day $daysSinceStarted of $estimatedDays • ${-daysRemaining} days overdue';
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return AppTheme.successGreen;
    if (progress >= 0.5) return AppTheme.accentTeal;
    if (progress >= 0.3) return AppTheme.warningAmber;
    return AppTheme.errorRed;
  }

  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}