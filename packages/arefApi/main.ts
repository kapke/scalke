import { Observable } from 'rxjs';

export interface RefBase<T> {
    onChange(cb: (t: T) => void): () => void;
    update(cb: (t: T) => T): Promise<T>;
    updateP<S>(fork: (t: T) => Promise<S>, join: (t: T, s: S) => T): Promise<T>;
}

export interface Ref<T> extends RefBase<T> {
    value$: Observable<T>;
}

export class RefWrap<T> implements Ref<T> {
    #wrapped: RefBase<T>;

    value$: Observable<T> = new Observable((subscriber) => {
        const tearDown = this.#wrapped.onChange(value => subscriber.next(value));
        return tearDown;
    })

    constructor(ref: RefBase<T>) {
        this.#wrapped = ref;
    }

    onChange(cb: (t: T) => void): () => void {
        return this.#wrapped.onChange(cb);
    }

    update(cb: (t: T) => T): Promise<T> {
        return this.#wrapped.update(cb);
    }

    updateP<S>(fork: (t: T) => Promise<S>, join: (t: T, s: S) => T): Promise<T> {
        return this.#wrapped.updateP(fork, join);
    }
}