import {JRef} from '../../../target/dist/main';
import { Ref, RefWrap, RefBase } from 'arefApi';

export class RefImpl<T> extends RefWrap<T> {
    static create<T>(initial: T): Promise<Ref<T>> {
        return JRef.create(initial).then(jref => new RefImpl(jref));
    }

    constructor(private jRef: RefBase<T>) {
        super(jRef);
    }
}