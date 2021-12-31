package kapke

import cats.effect.concurrent.Ref
import cats.implicits.*
import monix.eval.Task
import monix.reactive.Observable
import monix.reactive.subjects.{BehaviorSubject, Subject}

import scala.scalajs.js.annotation.{JSExport, JSExportAll, JSExportStatic, JSExportTopLevel}

case class ARef[T](private val ref: Ref[Task, T], private val subject: Subject[T, T]) {
  val value$: Observable[T] = subject

  def update(cb: T=>T): Task[T] =
    ref.updateAndGet(cb)
      .flatTap(value => Task {
        subject.onNext(value)
      })

  def updateT[B](fork: T => Task[B], join: (T, B) => T): Task[T] =
    for {
      initial <- ref.get
      forked <- fork(initial)
      result <- ref.updateAndGet(join(_, forked))
    } yield result
}
object ARef {
  def apply[T](initial: T): Task[ARef[T]] =
    for {
      ref <- Ref[Task].of(initial)
      subject <- Task { BehaviorSubject(initial) }
    } yield ARef(ref, subject)
}