// pdf_viewer_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class PdfViewerBloc extends Bloc<PdfViewerEvent, PdfViewerState> {
  PdfViewerBloc() : super(PdfViewerState()) {
    on<AddCommentEvent>(_onAddComment);
    on<SetLoadingEvent>(_onSetLoading);
  }

  void _onAddComment(AddCommentEvent event, Emitter<PdfViewerState> emit) {
    final newComments = Map<int, String>.from(state.comments);
    newComments[event.pageNumber] = event.comment;
    emit(state.copyWith(comments: newComments));
  }

  void _onSetLoading(SetLoadingEvent event, Emitter<PdfViewerState> emit) {
    emit(state.copyWith(isLoading: event.isLoading));
  }
}

abstract class PdfViewerEvent {}
class AddCommentEvent extends PdfViewerEvent {
  final int pageNumber;
  final String comment;
  AddCommentEvent(this.pageNumber, this.comment);
}
class SetLoadingEvent extends PdfViewerEvent {
  final bool isLoading;
  SetLoadingEvent(this.isLoading);
}

class PdfViewerState {
  final Map<int, String> comments;
  final bool isLoading;

  PdfViewerState({
    this.comments = const {},
    this.isLoading = false,
  });

  PdfViewerState copyWith({
    Map<int, String>? comments,
    bool? isLoading,
  }) {
    return PdfViewerState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}