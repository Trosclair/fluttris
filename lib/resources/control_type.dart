enum ControlType {
  rotateRight._('Rotate Right'),
  rotateLeft._('Rotate Left'),
  flip._('Flip'),
  hardDrop._('Hard Drop'),
  drop._('Drop'),
  hold._('Hold'),
  moveLeft._('Move Left'),
  moveRight._('Move Right'),
  pause._('Pause'),
  reset._('Reset');

  final String _value;

  const ControlType._(this._value);

  @override
  String toString() => _value;
}