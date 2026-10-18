"""Generate the Google Play feature graphic.

Play calls it the FEATURE GRAPHIC, it is mandatory for a listing, and
1024x500 is the only size it accepts (PNG or JPEG, no alpha, under 15MB).

The photograph is not redrawn here. It is assets/images/app_image.jpg, the
same scene as the snap banner in installers/feature_banner.png, cropped at
its native 1024px width so nothing is upscaled. The meditator sits on the
left; the sky on the right is bright, so a warm shade is laid over that side
for the type to sit on.

Play may overlay a play button over the CENTRE of this image when a promo
video is attached to the listing. InnerPod has no video, so the centre is
free — if one is ever added, check the type is not sitting under it.
"""

import os

import numpy as np
from PIL import Image, ImageDraw, ImageFont

W, H = 1024, 500
SS = 2                    # supersample, for clean type
NW, NH = W * SS, H * SS

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PHOTO = os.path.join(ROOT, 'assets', 'images', 'app_image.jpg')
OUT = os.path.join(ROOT, 'installers', 'feature_graphic.png')

FONTS = os.path.expanduser(
    '~/development/flutter/bin/cache/artifacts/material_fonts/'
)

# Taken from the photograph itself: the shade is the dark of the headland,
# the tagline the sunlit sand.

SHADE = (58, 26, 10)
CREAM = (255, 246, 232)
SAND = (255, 200, 130)

# The crop's top edge in the 1024px photograph. 110 keeps the flower in her
# hair and her hands together within the frame.

CROP_TOP = 110

TITLE = 'InnerPod'
TAGLINE = 'A timer for silent meditation'
THIRD = 'Privacy first: your data stays under your control'


def photo():
    """The photograph cropped to Play's aspect, then supersampled."""

    img = Image.open(PHOTO).convert('RGB')
    assert img.width == W, f'expected a {W}px wide photograph'
    img = img.crop((0, CROP_TOP, W, CROP_TOP + H))
    return img.resize((NW, NH), Image.LANCZOS).convert('RGBA')


def shade():
    """A warm shade rising from nothing at the figure to most of the right.

    It eases in rather than starting at a hard edge, so the photograph reads
    as one scene and the type still has a dark enough ground to be legible
    against the brightest part of the sky.
    """

    x = np.linspace(0, 1, NW, dtype=np.float32)
    ramp = np.clip((x - 0.36) / 0.30, 0, 1)
    ramp = ramp * ramp * (3 - 2 * ramp)           # smoothstep
    alpha = (ramp * 0.72 * 255).astype(np.uint8)

    layer = np.zeros((NH, NW, 4), dtype=np.uint8)
    layer[..., :3] = SHADE
    layer[..., 3] = alpha[None, :]
    return Image.fromarray(layer, 'RGBA')


def main():
    img = Image.alpha_composite(photo(), shade())
    draw = ImageDraw.Draw(img)

    title_font = ImageFont.truetype(FONTS + 'Roboto-Medium.ttf', 92 * SS)
    tag_font = ImageFont.truetype(FONTS + 'Roboto-Light.ttf', 34 * SS)
    third_font = ImageFont.truetype(FONTS + 'Roboto-Light.ttf', 21 * SS)

    tx = int(NW * 0.50)

    draw.text((tx, int(NH * 0.44)), TITLE, font=title_font,
              fill=CREAM + (255,), anchor='ls')
    draw.text((tx + 3 * SS, int(NH * 0.58)), TAGLINE, font=tag_font,
              fill=SAND + (255,), anchor='ls')
    draw.text((tx + 3 * SS, int(NH * 0.69)), THIRD, font=third_font,
              fill=CREAM + (210,), anchor='ls')

    for label, text, font in (('title', TITLE, title_font),
                              ('tagline', TAGLINE, tag_font),
                              ('third', THIRD, third_font)):
        right = tx + font.getbbox(text)[2]
        assert right < NW - int(NW * 0.04), (
            f'{label} reaches {right / SS:.0f}px of {W}, too close to the '
            f'edge — shorten it or drop the type size'
        )

    out = img.convert('RGB').resize((W, H), Image.LANCZOS)
    out.save(OUT, optimize=True)

    size = os.path.getsize(OUT)
    assert out.size == (1024, 500), f'{out.size} is not Play\'s 1024x500'
    assert size < 15 * 1024 * 1024, f'{size / 1024:.0f}kB is over 15MB'

    print(f'wrote {os.path.relpath(OUT, ROOT)}   {W}x{H}, {size / 1024:.0f}kB')


if __name__ == '__main__':
    main()
