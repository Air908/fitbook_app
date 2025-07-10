import 'package:flutter/material.dart';

import '../screens/home_screen.dart';

class QuickActions extends StatelessWidget {
  final List<QuickActionItem> actions;
  final Function(QuickActionItem) onActionTap;

  const QuickActions({
    Key? key,
    required this.actions,
    required this.onActionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const Center(child: Text("No quick actions available"));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.0,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];

        return Material(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onActionTap(action),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    radius: 20,
                    child: Icon(
                      action.icon,
                      size: 28,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    action.title.isNotEmpty ? action.title : 'Untitled',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    action.subtitle.isNotEmpty ? action.subtitle : 'No description',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
