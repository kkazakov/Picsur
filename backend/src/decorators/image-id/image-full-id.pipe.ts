import { Injectable, PipeTransform } from '@nestjs/common';
import { Ext2FileType } from 'picsur-shared/dist/dto/mimes.dto';
import { FT, Fail, HasFailed } from 'picsur-shared/dist/types/failable';
import { ShortCodeRegex } from 'picsur-shared/dist/util/common-regex';
import { ImageFullId } from '../../models/constants/image-full-id.const.js';

@Injectable()
export class ImageFullIdPipe implements PipeTransform<string, ImageFullId> {
  transform(value: string): ImageFullId {
    const split = value.split('.');
    if (split.length === 2) {
      const [id, ext] = split;
      if (!ShortCodeRegex.test(id))
        throw Fail(FT.UsrValidation, 'Invalid image identifier');

      const filetype = Ext2FileType(ext);

      if (HasFailed(filetype))
        throw Fail(FT.UsrValidation, 'Invalid image identifier');

      return { variant: 'normal', id, ext, filetype };
    } else if (split.length === 1) {
      const [id] = split;

      if (!ShortCodeRegex.test(id))
        throw Fail(FT.UsrValidation, 'Invalid image identifier');

      return { variant: 'original', id, ext: null, filetype: null };
    } else {
      throw Fail(FT.UsrValidation, 'Invalid image identifier');
    }
  }
}
