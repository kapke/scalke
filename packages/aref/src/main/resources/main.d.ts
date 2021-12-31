import { RefBase } from 'arefApi';

export class JRef<T> implements RefBase<T> {
    static create<T> (initial: T): Promise<JRef<T>>

    onChange(cb: (t: T) => void): () => void;

    update(cb: (t: T) => T): Promise<T>;

    updateP<S>(fork: (t: T) => Promise<S>, join: (t: T, s: S) => T): Promise<T>;
}