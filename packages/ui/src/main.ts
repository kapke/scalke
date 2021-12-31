import { take, tap } from "rxjs";
import {Timer} from "./timer";

console.log("Started")

Timer.create().then(timer => {
    timer.time$.pipe(
        take(10),
    ).subscribe({
            next: (value) => console.log({value}),
            error: (error) => console.error({error}),
            complete: () => console.log("Finish")
        }
    )
})
