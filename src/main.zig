const std = @import("std");
const rl = @import("raylib");

const GameScreen = enum {
    logo,
    title,
    gameplay,
    ending,
};

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screen_width = 800;
    const screen_height = 450;

    rl.initWindow(screen_width, screen_height, "Vektor");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.disableCursor();
    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second

    var current_screen: GameScreen = GameScreen.logo;
    var intro_frame_counter: u32 = 0;

    var fps_buffer: [32]u8 = undefined;

    var camera = rl.Camera3D{
        .position = .init(10, 10, 10),
        .target = .init(0, 0, 0),
        .up = .init(0, 1, 0),
        .fovy = 45,
        .projection = .perspective,
    };

    const cubePosition = rl.Vector3.init(0, 0, 0);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        switch (current_screen) {
            .logo => {
                intro_frame_counter += 1;
                if (intro_frame_counter > 120) {
                    current_screen = .title;
                }
            },
            .title => {
                if (rl.isKeyPressed(.enter) or rl.isGestureDetected(.tap)) {
                    current_screen = .gameplay;
                }
            },
            .gameplay => {
                // Update
                camera.update(.free);

                if (rl.isKeyPressed(.z)) {
                    camera.target = .init(0, 0, 0);
                }

                if (rl.isKeyPressed(.enter) or rl.isGestureDetected(.tap)) {
                    current_screen = .ending;
                }
            },
            .ending => {
                if (rl.isKeyPressed(.enter) or rl.isGestureDetected(.tap)) {
                    current_screen = .logo;
                }
            },
        }

        const text: [:0]const u8 = try std.fmt.bufPrintZ(&fps_buffer, "FPS: {}", .{rl.getFPS()});

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        switch (current_screen) {
            .logo => {
                rl.drawText("LOGO SCREEN", 20, 20, 40, .light_gray);
                rl.drawText("WAIT for 2 SECONDS...", 290, 220, 20, .gray);
            },
            .title => {
                rl.drawRectangle(0, 0, screen_width, screen_height, .green);
                rl.drawText("TITLE SCREEN", 20, 20, 40, .dark_green);
                rl.drawText("PRESS ENTER or TAP to JUMP to GAMEPLAY SCREEN", 120, 220, 20, .dark_green);
            },
            .gameplay => {
                camera.begin();
                defer camera.end();

                rl.drawCube(cubePosition, 2, 2, 2, .gold);
                rl.drawCubeWires(cubePosition, 2, 2, 2, .maroon);

                rl.drawGrid(10, 1);

                rl.drawText(text, 10, 10, 10, .black);
                rl.drawRectangle(10, 10, 320, 93, .fade(.sky_blue, 0.5));
                rl.drawRectangleLines(10, 10, 320, 93, .blue);

                rl.drawText("Free camera default controls:", 20, 20, 10, .black);
                rl.drawText("- Mouse Wheel to Zoom in-out", 40, 40, 10, .dark_gray);
                rl.drawText("- Mouse Wheel Pressed to Pan", 40, 60, 10, .dark_gray);
                rl.drawText("- Z to zoom to (0, 0, 0)", 40, 80, 10, .dark_gray);
            },
            .ending => {
                rl.drawRectangle(0, 0, screen_width, screen_height, .blue);
                rl.drawText("ENDING SCREEN", 20, 20, 40, .dark_blue);
                rl.drawText("PRESS ENTER to TAP to RETURN to TITLE SCREEN", 120, 220, 20, .dark_blue);
            },
        }

        //----------------------------------------------------------------------------------
    }
}
