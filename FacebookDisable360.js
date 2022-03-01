/*

Disables the 360 feature of photos uploaded to Facebook, which is necessary to 
get 3D photos to appear side-by-side, or panoramas to appear as non-interactive
panoramas.

Use this as a bookmarklet on the "Add Photos" screen when uploading photos to 
an album (must be done at the point of upload; the option isn't there after 
images are posted to the album). Manually this can be done by clicking the 
settings icon at the bottom right of each image, clicking "Select Starting 
View" and unchecking the "Display as a 360 photo" checkbox.

To test: 
Make changes and copy the entire IIFE into the console

To use as a bookmarklet: 
Smoosh the function into a single line by coping only the internals of the 
IIFE into https://mrcoles.com/bookmarklet/ and copy the result as the URL for 
the bookmark

*/

(function () {
    /* Get all the "Select Starting View" menu items to show up */
    document.querySelectorAll("a[tooltip='Settings']").forEach((settingsButton) => {
        settingsButton.click();
    });

    /* Open the 360 settings page for each picture */
    document.querySelectorAll("div[role='menuitem']").forEach((selectStartingViewButton) => {
        selectStartingViewButton.click();
    });

    /* Find and uncheck all the "Display as a 360 photo" checkboxes */
    document.querySelectorAll("input[name='enable360']").forEach((enable360Checkbox) => {
        if (enable360Checkbox.checked) {
            enable360Checkbox.click();
        }
    });

    /* Click all the "Save" buttons */
    document.querySelectorAll("button[action='confirm']").forEach((saveButton) => {
        saveButton.click();
    });
})();