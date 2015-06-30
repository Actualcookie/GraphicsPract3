using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.GamerServices;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Media;

namespace GraphicsPractical2
{
    public class Game1 : Microsoft.Xna.Framework.Game
    {
        // Often used XNA objects
        private GraphicsDeviceManager graphics;
        private SpriteBatch spriteBatch;
        private FrameRateCounter frameRateCounter;
        RenderTarget2D renderTarget;
        Effect postEffect;

        // Game objects and variables
        private Camera camera;

        // Model
        private Model model;
        private Material modelMaterial;
        private Vector4[] lightPosition = new Vector4[10];
        private Vector4[] diffuseColor= new Vector4[10];
        private Matrix World, ITWorld;

        public Game1()
        {
            this.graphics = new GraphicsDeviceManager(this);
            this.Content.RootDirectory = "Content";
            // Create and add a frame rate counter
            this.frameRateCounter = new FrameRateCounter(this);
            this.Components.Add(this.frameRateCounter);
        }

        protected override void Initialize()
        {
            // Copy over the device's rasterizer state to change the current fillMode
            this.GraphicsDevice.RasterizerState = new RasterizerState() { CullMode = CullMode.None };
            // Set up the window
            this.graphics.PreferredBackBufferWidth = 800;
            this.graphics.PreferredBackBufferHeight = 600;
            this.graphics.IsFullScreen = false;
            // Let the renderer draw and update as often as possible
            this.graphics.SynchronizeWithVerticalRetrace = false;
            this.IsFixedTimeStep = false;
            // Flush the changes to the device parameters to the graphics card
            this.graphics.ApplyChanges();
            // Initialize the camera
            this.camera = new Camera(new Vector3(0, 50, 100), new Vector3(0, 0, 0), new Vector3(0, 1, 0));

            this.IsMouseVisible = true;

            base.Initialize();


            renderTarget = new RenderTarget2D( GraphicsDevice, GraphicsDevice.PresentationParameters.BackBufferWidth, 
                GraphicsDevice.PresentationParameters.BackBufferHeight, false, GraphicsDevice.PresentationParameters.BackBufferFormat, DepthFormat.Depth24);
        }

        protected override void LoadContent()
        {
            // Create a SpriteBatch object
            this.spriteBatch = new SpriteBatch(this.GraphicsDevice);

            // Load the effects
            Effect effect = this.Content.Load<Effect>("Effects/Spotlight");
            postEffect = this.Content.Load<Effect>("Effects/Grayscale");

            modelMaterial.SetEffectParameters(effect);

            // Load the model and let it use the "CellShade" effect
            this.model = this.Content.Load<Model>("Models/Teapot");
            this.model.Meshes[0].MeshParts[0].Effect = effect;

        }

        //Draws the 3d scene to a texture
        protected Texture2D CreateTexture(RenderTarget2D renderTarget)
        {
            // Set the render target
            GraphicsDevice.SetRenderTarget(renderTarget);

            GraphicsDevice.Clear(Color.CornflowerBlue);
           /* Vector3 lightdirection = new Vector3(1, 1, 1);
            effect.Parameters["LightDirection"].SetValue(lightdirection);*/
           /* FillArray(lightPosition);
            effect.Parameters["lightPosition"].SetValue(lightPosition);
            FillArray(diffuseColor);
            effect.Parameters["diffuseColors"].SetValue(diffuseColor); */
        }

        public void FillArray(Vector4[] fill)
        {   
            Random r = new Random();
            //generates a array of random variables which act as the light positions and the light colors
            for(int i=0;i< fill.Length;i++)
            {
                Vector4 vary= new Vector4(r.Next(-20,15),r.Next(-20,15),r.Next(-15,25),r.Next(-20,15));
                fill[i] = vary;             
            }

        }
        protected override void Update(GameTime gameTime)
        {
            float timeStep = (float)gameTime.ElapsedGameTime.TotalSeconds * 60.0f;
            
            // Update the window title
            this.Window.Title = "XNA Renderer | FPS: " + this.frameRateCounter.FrameRate;
           //warning flashing lights for status checking only (and or disco parties involving tea)
            ModelMesh mesh = this.model.Meshes[0];
            Effect effect = mesh.Effects[0];
            FillArray(lightPosition);
            effect.Parameters["lightPosition"].SetValue(lightPosition);
            FillArray(diffuseColor);
            effect.Parameters["diffuseColors"].SetValue(diffuseColor); 

            //Draw the model
            ModelMesh mesh = this.model.Meshes[0];
            Effect effect = mesh.Effects[0];

            // Set the effect parameters
            effect.CurrentTechnique = effect.Techniques["Simple"];
            // Matrices for 3D perspective projection
            this.camera.SetEffectParameters(effect);

            World = Matrix.CreateScale(10.0f);
            Vector3 lightdirection = new Vector3(-1, -1, -1);
            Vector3 lightposition = new Vector3(50,50, 50);

            effect.Parameters["LightDirection"].SetValue(lightdirection);


            if(effect.Parameters["LightPosition"] != null)
            effect.Parameters["LightPosition"].SetValue(lightposition);

            Matrix ITWorld = Matrix.Transpose(Matrix.Invert(World));

            effect.Parameters["World"].SetValue(World);
            effect.Parameters["ITWorld"].SetValue(ITWorld);

            // Draw the model
            mesh.Draw();

            // Drop the render target
            GraphicsDevice.SetRenderTarget(null);

            // Return the texture in the render target
            return renderTarget;
        }

        protected override void Update(GameTime gameTime)
        {
            float timeStep = (float)gameTime.ElapsedGameTime.TotalSeconds * 60.0f;

            // Update the window title
            this.Window.Title = "XNA Renderer | FPS: " + this.frameRateCounter.FrameRate;

            base.Update(gameTime);
        }

        protected override void Draw(GameTime gameTime)
        {
            Texture2D texture = CreateTexture(renderTarget);
            //set the backbuffer to black
            GraphicsDevice.Clear(Color.Black);


            spriteBatch.Begin(SpriteSortMode.Deferred, BlendState.Opaque,
                SamplerState.LinearClamp, DepthStencilState.Default,
                RasterizerState.CullNone);

            spriteBatch.Draw(texture, new Rectangle(0, 0, 800, 600), Color.White);

            spriteBatch.End();

            base.Draw(gameTime);
        }
    }
}
