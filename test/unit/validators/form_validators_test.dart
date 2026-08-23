import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('returns error when null', () {
      expect(Validators.email(null), isNotNull);
    });

    test('returns error when empty', () {
      expect(Validators.email(''), 'Email is required');
    });

    test('returns error when whitespace only', () {
      expect(Validators.email('   '), 'Email is required');
    });

    test('returns error for invalid email format', () {
      expect(Validators.email('notanemail'), isNotNull);
      expect(Validators.email('missing@'), isNotNull);
      expect(Validators.email('@domain.com'), isNotNull);
      expect(Validators.email('no spaces@test.com'), isNotNull);
    });

    test('returns null for valid email', () {
      expect(Validators.email('test@example.com'), isNull);
      expect(Validators.email('user.name@domain.co.uk'), isNull);
      expect(Validators.email('ava.admin@nimbusdigital.test'), isNull);
    });
  });

  group('Validators.password', () {
    test('returns error when null', () {
      expect(Validators.password(null), isNotNull);
    });

    test('returns error when empty', () {
      expect(Validators.password(''), 'Password is required');
    });

    test('returns error when too short', () {
      expect(Validators.password('Ab1!'), isNotNull);
    });

    test('returns error when no uppercase', () {
      expect(Validators.password('password1!'), isNotNull);
    });

    test('returns error when no lowercase', () {
      expect(Validators.password('PASSWORD1!'), isNotNull);
    });

    test('returns error when no number', () {
      expect(Validators.password('Password!'), isNotNull);
    });

    test('returns error when no special character', () {
      expect(Validators.password('Password1'), isNotNull);
    });

    test('returns null for valid password', () {
      expect(Validators.password('Password123!'), isNull);
      expect(Validators.password('Str0ng@Pass'), isNull);
    });
  });

  group('Validators.required', () {
    test('returns error when null', () {
      expect(Validators.required(null), isNotNull);
    });

    test('returns error when empty', () {
      expect(Validators.required(''), isNotNull);
    });

    test('returns error when whitespace only', () {
      expect(Validators.required('   '), isNotNull);
    });

    test('returns null when has value', () {
      expect(Validators.required('hello'), isNull);
    });

    test('uses custom field name', () {
      expect(Validators.required('', 'Title'), 'Title is required');
    });
  });

  group('Validators.taskTitle', () {
    test('returns error when empty', () {
      expect(Validators.taskTitle(''), isNotNull);
    });

    test('returns error when too short', () {
      expect(Validators.taskTitle('ab'), isNotNull);
    });

    test('returns error when too long', () {
      expect(Validators.taskTitle('a' * 201), isNotNull);
    });

    test('returns null for valid title', () {
      expect(Validators.taskTitle('Fix broken contact form'), isNull);
      expect(Validators.taskTitle('abc'), isNull);
    });
  });

  group('Validators.projectName', () {
    test('returns error when empty', () {
      expect(Validators.projectName(''), isNotNull);
    });

    test('returns error when too short', () {
      expect(Validators.projectName('ab'), isNotNull);
    });

    test('returns null for valid name', () {
      expect(Validators.projectName('Website Relaunch'), isNull);
    });
  });
}
