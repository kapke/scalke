package kapke

import monix.eval.Task
import monix.execution.{Ack, Cancelable}

import scala.scalajs.js
import scalajs.js.annotation.{JSExportAll, JSExportStatic, JSExportTopLevel}
import js.JSConverters.*
import monix.execution.Scheduler.Implicits.global

import scala.concurrent.Future

@JSExportTopLevel("JRef")
class JRef[T](private val ref: ARef[T]) extends js.Object with typings.arefApi.mod.RefBase[T] {
  Console.println("JRef constructor")
  def onChange(cb: js.Function1[T, Unit]): js.Function0[Unit] = {
    val subscription: Cancelable = ref.value$.subscribe(nextFn = cb.andThen(_ => Future.successful(Ack.Continue)))
    subscription.cancel _
  }

  def update(cb: js.Function1[T, T]): js.Promise[T] =
    ref.update(cb).runToFuture.toJSPromise

  def updateP[S](fork: js.Function1[T, js.Promise[S]], join: js.Function2[T, S, T]): js.Promise[T] =
    ref.updateT(
      fork = (t: T) => Task.deferFuture(fork(t).toFuture),
      join = join
    ).runToFuture.toJSPromise
}
object JRef {
  @JSExportStatic
  def create[T](initial: T): js.Promise[JRef[T]] = {
    Console.println("Aref.create")
    ARef(initial)
      .map(new JRef(_))
      .runToFuture
      .toJSPromise
  }
}
