package editors

import (
	"github.com/fogleman/gg"
	"image"
)

func init() {
	Editors["hollowCircle"] = &Editor{
		Name:        "Hollow Circle",
		Description: "Draws a hollow circle on the screen.",
		Icon:        EditorAssets.Bytes("hollow_circle.png"),
		Apply: func(Region *image.RGBA, RGB [3]uint8) *image.RGBA {
			// Creates the image.
			img := image.NewRGBA(Region.Bounds())
			for i, v := range Region.Pix {
				img.Pix[i] = v
			}

			// Draws the circle.
			Radius := Region.Bounds().Dx()
			if Radius > Region.Bounds().Dy() {
				Radius = Region.Bounds().Dy()
			}
			dc := gg.NewContext(img.Bounds().Dx(), img.Bounds().Dy())
			dc.DrawCircle(float64(Region.Bounds().Dx()), float64(Region.Bounds().Dy()), float64(Radius))
			dc.SetRGB(float64(RGB[0]), float64(RGB[1]), float64(RGB[2]))
			dc.DrawImage(img, 0, 0)

			// Returns the image.
			return img
		},
	}
}
