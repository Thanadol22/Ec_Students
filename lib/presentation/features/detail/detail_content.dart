import 'package:ec_student/models/document_model.dart';
import 'package:ec_student/presentation/common/status_chip.dart';
import 'package:flutter/material.dart';

class DetailContent extends StatelessWidget {
  final MainAxisSize _mainAxisSize;
  final ManualsModel _document;
  final CrossAxisAlignment _crossAxisAlignment;
  const DetailContent({
    Key? key,
    MainAxisSize mainAxisSize = MainAxisSize.min,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    bool hasBorrowed = false,
    required ManualsModel document,
  })  : _mainAxisSize = mainAxisSize,
        _document = document,
        _crossAxisAlignment = crossAxisAlignment,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: _crossAxisAlignment,
      mainAxisSize: _mainAxisSize,
      children: <Widget>[
        StatusChip(
          status: _document.history?.status ?? '',
          name: _document.history?.user?.name,
        ),
        Text(
          _document.projectName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(
          height: 24,
        ),
        Text(
          _document.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          _document.department,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          _document.level,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
