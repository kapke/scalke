import { RefImpl } from 'aref';
import {Ref} from 'arefApi';
import { concatMap, interval, map, Observable } from 'rxjs';

export class Timer {
    static create() {
        return RefImpl.create(new Date()).then(ref => new Timer(ref))
    }

    #ref: Ref<Date>;

    time$: Observable<Date>;

    constructor(ref: Ref<Date>) {
        this.#ref = ref
        this.time$ = interval(1000).pipe(
            map(_ => new Date()),
            concatMap(date => this.#ref.update(_ => date)),
        )
    }
}
