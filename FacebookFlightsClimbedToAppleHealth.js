/*
Turns out, this method doesn't work but I'm saving the code for future
reference. The numbers that are reported in the image's alt text on Facebook
aren't in any consistent order, so they're pretty much useless.

Syncs the number of flights climbed, as found in the auto-generated alt text of
images uploaded to Facebook, to Apple Health.

Use this as a bookmarklet inside the album containing photos of the Matrix C7xe
climbmill's screen as it shows the workout summary.

Manually this can be done by right-clicking on the image, inspecting in chrome
and viewing the alt text of the img tag.

To test: Make changes and copy the entire IIFE into the console

To use as a bookmarklet: Smoosh the function into a single line by coping only
the internals of the IIFE into https://mrcoles.com/bookmarklet/ and copy the
result as the URL for the bookmark
*/

class WorkoutStats {
    // altText should be of a form similar to "Image may contain: screen, text
    // that says '80 5/60 Workout Summary Expanded Workout Down Total Time
    // Elapsed Steps Floors Climbed Calories 5:00 1:39:00 7272 454 1065 1:44:00
    // 7392 462 1087 8 22'"
    //
    // This example should parse to the following: hours = 1 minutes = 44
    // seconds = 0 steps = 7392 floors = 462 calories = 1087
    constructor(altText) {
        console.log('creating ' + altText);

        // Note: this does not work consistently. The numbers in the alt text
        // aren't always in this order.
        var results = [...altText.matchAll(/(((\d):)?(\d?\d):(\d\d)) (\d+) (\d+) (\d+)/g)].pop()
        if (results && results.length == 9) {
            this.hours = results[3] ? parseInt(results[3]) : 0
            this.minutes = parseInt(results[4])
            this.seconds = parseInt(results[5])
            this.steps = parseInt(results[6])
            this.floors = parseInt(results[7])
            this.calories = parseInt(results[8])
        }
        console.log(this.isValid());
    }

    isValid = () => {
        return this.minutes
            && this.seconds
            && this.steps > 0
            && this.floors > 0
            && this.calories > 0;
    }
}

(function () {
    var workoutStats = []
    var workoutStatsByDate = new Map();

    /* Click all the pencil edit icons */
    document.querySelectorAll("i[class='hu5pjgll eb18blue sp_dj2YEykniis_3x sx_f84d50']").forEach((editButton) => {
        editButton.click();

        var altText = editButton.parentNode.parentNode.previousSibling.previousSibling.alt;
        var stats = new WorkoutStats(altText)

        // Store the workout stats in the order we encounter them. This order
        // will match the order we find the dates later.
        workoutStats.push(stats);

        // Get the date the photo was taken (luckily this seems to use photo
        // metadata, not upload date)
        window.setTimeout(($$) => {
            console.log("clicking 'pencil edit icon' finished");

            /* Gather all the "Edit date" buttons. We do it this way so we know
            when we're clicking the last one. */
            var editDateButtons = $$('span').filter(function (span) {
                return span.innerText.includes('Edit date');
            });

            /* Click each "Edit date" button */
            editDateButtons.forEach((function (editDateButton, editDateButtonIndex) {
                console.log("clicking 'Edit date'");
                editDateButton.click()

                // After clicking the last button, gather all the dates and
                // close all the dialogs */
                if (editDateButtonIndex == editDateButtons.length - 1) {

                    window.setTimeout(($$) => {
                        console.log("clicking final 'Edit date' button finished");

                        /* Get the date text from the first child of the
                        sibling of the "Date" label */
                        $$('span').filter(function (span) {
                            return span.innerText == 'Date'
                        }).forEach((dateLabel) => {
                            var dateText = dateLabel.nextSibling.children[0].value;
                            var date = new Date(dateText);

                            console.log('length before shifting: ' + workoutStats.length);

                            // Pull out the stats at the beginning of the
                            // array. This should match the picture whose date
                            // we just found, as we should be processing them
                            // in the same order.
                            var stats = workoutStats.shift();
                            console.log(stats.isValid());

                            // We might have multiple pictures with the same
                            // date, so we want to make sure to use one with
                            // valid stats.
                            if (stats.isValid()) {
                                workoutStatsByDate[date] = stats;
                            }
                        });

                        console.log("clicking cancel button");
                        /* Click the "Cancel" button to dismiss the dialog */
                        $$('span').filter(function (span) {
                            return span.innerText == 'Cancel';
                        })[0].click();

                        window.setTimeout(($$) => {
                            console.log("clicking 'cancel' finished");

                            logToAppleHealth(workoutStatsByDate);
                        }, 0, $$);
                    }, 0, $$);
                }
            }))
        }, 0, $$);
    });
})();

logToAppleHealth = (workoutStatsByDate) => {
    console.log(workoutStatsByDate);
}
