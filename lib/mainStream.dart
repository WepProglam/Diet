library mainStream;

import 'dart:async';

StreamController<Map> streamController = StreamController<Map>.broadcast();
StreamController<bool> streamControllerBool =
    StreamController<bool>.broadcast();
int a = 0;
