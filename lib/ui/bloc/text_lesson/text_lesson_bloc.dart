import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/cache/cache_manager.dart';
import 'package:masterstudy_app/data/repository/lesson_repository.dart';

import './bloc.dart';

@provide
class TextLessonBloc extends Bloc<TextLessonEvent, TextLessonState> {
  final LessonRepository repository;
  final CacheManager cacheManager;

  TextLessonBloc(this.repository, this.cacheManager);

  @override
  TextLessonState get initialState => InitialTextLessonState();

  @override
  Stream<TextLessonState> mapEventToState(
    TextLessonEvent event,
  ) async* {
    if (event is FetchEvent) {
      try{
        var response = await repository.getLesson(event.courseId, event.lessonId);
        print(response);
        yield LoadedTextLessonState(response);
        if(response.fromCache && response.type == "slides"){
          yield CacheWarningLessonState();
        }
      }catch(e,s){
        print(e);
        print(s);
      }
    }else if (event is CompleteLessonEvent){
      try{
        var response = await repository.completeLesson(event.courseId, event.lessonId);
      }catch(e,s){
        print(e);
        print(s);
      }
    }
  }
}
