import 'package:flutter/material.dart';

import '../../../theme/potok_theme.dart';

class DefaultPotokButton extends StatelessWidget {
  const DefaultPotokButton({super.key, this.onTap, this.icon, required this.text, this.backgroundColor, this.isLoading = false});
  final Function()? onTap;
  final IconData? icon;
  final String text;
  final bool isLoading;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    var theme = PotokTheme.of(context);

    return InkWell(
      onTap: isLoading ? () {} : onTap,
      borderRadius: BorderRadius.circular(15.5),
      splashColor: theme.frontColor,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        width: MediaQuery.of(context).size.width * 0.9,
        height: 44.0,
        child: Container(
          padding: const EdgeInsets.only(left: 16.0, right: 8.0),
            decoration: BoxDecoration(
              color: onTap != null 
                ? backgroundColor ?? theme.backgroundColor
                : (backgroundColor ?? theme.backgroundColor).withOpacity(.5),
              borderRadius: BorderRadius.circular(15.0),
            ),
            
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (icon != null) Icon(icon, size: 22, color: onTap != null ? theme.iconColor : theme.iconColor.withOpacity(.5)),
                Expanded(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: onTap != null ? theme.textColor : theme.textColor.withOpacity(0.2)),
                  ),
                ),
                isLoading 
                ? const CircularProgressIndicator.adaptive()
                : Icon(Icons.chevron_right, size: 22,color: onTap != null ? theme.iconColor : theme.iconColor.withOpacity(.5)),
              ],
            )),
      ),
    );
  }
}