import 'package:flutter/material.dart';

class SigninFooter extends StatelessWidget {
  const SigninFooter({
    Key? key,
    required String label,
    required String buttonLabel,
    required VoidCallback onNavigate,
  })  : _label = label,
        _buttonLabel = buttonLabel,
        voidCallBack = onNavigate,
        super(key: key);

  final String _label;
  final String _buttonLabel;
  final VoidCallback voidCallBack;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _label,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          TextButton(
            onPressed: voidCallBack,
            child: Text(
              _buttonLabel,
              style: Theme.of(context).textTheme.titleSmall?.merge(TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
