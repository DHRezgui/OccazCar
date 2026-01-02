import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/models/message_model.dart';

void main() {
  test('MessageModel fromJson/toJson roundtrip', () {
    final now = DateTime.now();
    final json = {
      'id': '1',
      'fromId': 'a',
      'toId': 'b',
      'text': 'hello',
      'timestamp': now.toIso8601String(),
    };

    final m = MessageModel.fromJson(json);
    final out = m.toJson();

    expect(out['id'], '1');
    expect(out['fromId'], 'a');
    expect(out['toId'], 'b');
    expect(out['text'], 'hello');
    expect(
      DateTime.parse(out['timestamp'] as String).toIso8601String(),
      now.toIso8601String(),
    );
  });
}
