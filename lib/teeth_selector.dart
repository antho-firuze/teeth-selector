import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:teeth_selector/svg.dart';
import 'package:xml/xml.dart';

typedef Data = ({Size size, Map<String, Tooth> teeth});

class TeethSelector extends StatefulWidget {
  final bool multiSelect;
  final Color selectedColor;
  final Color tooltipColor;
  final List<String> initiallySelected;
  final Map<String, Color> colorized;
  final String leftString;
  final String rightString;
  final bool showPrimary;
  final bool showPermanent;
  final void Function(List<String> selected) onChange;
  final String Function(String isoString)? notation;

  const TeethSelector({
    super.key,
    this.multiSelect = false,
    this.selectedColor = Colors.blue,
    this.tooltipColor = Colors.black,
    this.initiallySelected = const [],
    this.colorized = const {},
    this.notation,
    this.showPrimary = false,
    this.showPermanent = true,
    this.leftString = "Left",
    this.rightString = "Right",
    required this.onChange,
  });

  @override
  State<TeethSelector> createState() => _TeethSelectorState();
}

class _TeethSelectorState extends State<TeethSelector> {
  Data data = loadTeeth();

  @override
  void initState() {
    for (var element in widget.initiallySelected) {
      if (data.teeth[element] != null) {
        data.teeth[element]!.selected = true;
      }
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    if (data.size == Size.zero) return const UnconstrainedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FittedBox(
          child: SizedBox.fromSize(
            size: data.size,
            child: Stack(
              children: [
                Positioned(
                  left: 10,
                  top: data.size.height * 0.5 - 15,
                  child: Text(widget.rightString),
                ),
                Positioned(
                  right: 10,
                  top: data.size.height * 0.5 - 15,
                  child: Text(widget.leftString),
                ),
                // teeth
                for (final MapEntry(key: key, value: tooth) in data.teeth.entries)
                  if ((widget.showPrimary || int.parse(key) < 50) && (widget.showPermanent || int.parse(key) > 50))
                    Positioned.fromRect(
                      rect: tooth.rect,
                      child: GestureDetector(
                        key: Key("tooth-iso-$key-${tooth.selected ? "selected" : "not-selected"}"),
                        onTap: () {
                          setState(() {
                            if (widget.multiSelect == false) {
                              for (final tooth in data.teeth.entries) {
                                if (tooth.key != key) {
                                  tooth.value.selected = false;
                                }
                              }
                            }
                            tooth.selected = !tooth.selected;
                            widget.onChange(data.teeth.entries
                                .where((tooth) => tooth.value.selected)
                                .map((tooth) => tooth.key)
                                .toList());
                          });
                        },
                        child: Tooltip(
                          triggerMode: TooltipTriggerMode.manual,
                          message: widget.notation == null ? key : widget.notation!(key),
                          textAlign: TextAlign.center,
                          preferBelow: false,
                          decoration: BoxDecoration(color: widget.tooltipColor, boxShadow: kElevationToShadow[6]),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: tooth.selected ? widget.selectedColor : widget.colorized[key] ?? Colors.white,
                              shape: ToothBorder(tooth.path),
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Data loadTeeth() {
  final doc = XmlDocument.parse(svgString);
  final viewBox = doc.rootElement.getAttribute('viewBox')!.split(' ');
  final w = double.parse(viewBox[2]);
  final h = double.parse(viewBox[3]);

  final teeth = doc.rootElement.findAllElements('path');
  return (
    size: Size(w, h),
    teeth: <String, Tooth>{
      for (final tooth in teeth) tooth.getAttribute('id')!: Tooth(parseSvgPathData(tooth.getAttribute('d')!)),
    },
  );
}

class Tooth {
  Tooth(Path originalPath) {
    rect = originalPath.getBounds();
    path = originalPath.shift(-rect.topLeft);
  }

  late final Path path;
  late final Rect rect;
  bool selected = false;
}

class ToothBorder extends ShapeBorder {
  const ToothBorder(this.path);

  final Path path;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return rect.topLeft == Offset.zero ? path : path.shift(rect.topLeft);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black54;
    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
