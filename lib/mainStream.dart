library mainStream;

import 'dart:async';

StreamController<Map> streamController = StreamController<Map>.broadcast();

StreamController<bool> streamControllerBool =
    StreamController<bool>.broadcast();

StreamController<String> streamControllerString =
    StreamController<String>.broadcast();
