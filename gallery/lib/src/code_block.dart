import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';

final class CodeBlock extends StatefulWidget {
  const CodeBlock({super.key, required this.code});

  final String code;

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

final class _CodeBlockState extends State<CodeBlock> {
  static const _confirmationStays = Duration(milliseconds: 1600);

  var _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(_confirmationStays, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
    decoration: BoxDecoration(
      color: GalleryColors.ink,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              widget.code,
              style: const TextStyle(
                fontFamily: 'Menlo',
                fontFamilyFallback: ['Roboto Mono', 'monospace'],
                fontSize: 13,
                height: 1.5,
                color: GalleryColors.paper,
              ),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: _copy,
          style: TextButton.styleFrom(foregroundColor: GalleryColors.paper),
          icon: Icon(
            _copied ? CupertinoIcons.checkmark_alt : CupertinoIcons.doc_on_doc,
            size: 16,
          ),
          label: Text(_copied ? 'Copied' : 'Copy'),
        ),
      ],
    ),
  );
}
