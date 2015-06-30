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
        SpriteFont Font;
        KeyboardState newState, oldState;
        // Often used XNA objects
        int solution = 0;
        //0 = cellshade, 1= greyscale, 2 = spotlight, 3= multilight
        private GraphicsDeviceManager graphics;
        private SpriteBatch spriteBatch;
        private FrameRateCounter frameRateCounter;
        RenderTarget2D renderTarget;
        Effect Cell, Grayscale, Spotlight, MultiLight, Simple;

        // Game objects and variables
        private Camera camera;

        // Model
        private Model model;
        private Material modelMaterial;
        private Vector4[] lightPosition = new Vector4[10];
        private Vector4[] diffuseColor= new Vector4[10];
        private Matrix World, ITWorld;

        //Quad
        private VertexPositionNormalTexture[] quadVertices;
        private short[] quadIndices;
        private Matrix quadTransform;

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
            Font = Content.Load<SpriteFont>("Font");
            // Load the effects
            MultiLight= this.Content.Load<Effect>("Effects/Lights");
            Cell = this.Content.Load<Effect>("Effects/CellShade");
            Grayscale = this.Content.Load<Effect>("Effects/Grayscale");
            Spotlight = this.Content.Load<Effect>("Effects/SpotLight");
            Simple = this.Content.Load<Effect>("Effects/Simple");

            // Load the model and let it use the "CellShade" effect
            this.model = this.Content.Load<Model>("Models/femalehead");
            this.setupQuad();
            FillArray(diffuseColor);
            FillArray(lightPosition);

        }

        private void setupQuad()
        {
            float scale = 50.0f;

            // Normal points up
            Vector3 quadNormal = new Vector3(0, 1, 0);

            this.quadVertices = new VertexPositionNormalTexture[4];
            // Top left
            this.quadVertices[0].Position = new Vector3(-100, -30f, -100);
            // Top right
            this.quadVertices[1].Position = new Vector3(100, -30f, -100);
            // Bottom left
            this.quadVertices[2].Position = new Vector3(-100, -30f, 100);
            // Bottom right
            this.quadVertices[3].Position = new Vector3(100, -30, 100);

            this.quadIndices = new short[] { 0, 1, 2, 1, 2, 3 };
            this.quadTransform = Matrix.CreateScale(scale);
        }

        //Draws the 3d scene to a texture
        protected Texture2D CreateTexture(RenderTarget2D renderTarget)
        {
            // Set the render target
            GraphicsDevice.SetRenderTarget(renderTarget);

            GraphicsDevice.Clear(Color.CornflowerBlue);

            //Draw the model
            ModelMesh mesh = this.model.Meshes[0];
            Effect effect = mesh.Effects[0];
            foreach (EffectPass pass in effect.CurrentTechnique.Passes)
            {
                pass.Apply();
                GraphicsDevice.DrawUserIndexedPrimitives(PrimitiveType.TriangleList, quadVertices, 0, 4, quadIndices, 0, 2);
            }

            // Set the effect parameters
            effect.CurrentTechnique = effect.Techniques["Simple"];
            // Matrices for 3D perspective projection
            this.camera.SetEffectParameters(effect);

            World = Matrix.CreateScale(1);
            Vector3 lightdirection = new Vector3(-1,-1, -1);
            Vector3 lightposition = new Vector3(100, 0, 0);

            if (effect.Parameters["LightDirection"] != null)
            effect.Parameters["LightDirection"].SetValue(lightdirection);


            if (effect.Parameters["LightPosition"] != null)
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

        public void FillArray(Vector4[] fill)
        {   
            Random r = new Random();
            //generates a array of random variables which act as the light positions and the light colors
            for(int i=0;i< fill.Length;i++)
            {
                Vector4 vary= new Vector4(r.Next(-10,15),r.Next(-10,15),r.Next(-25,25),r.Next(15));
                fill[i] = vary;             
            }

        }

        protected override void Update(GameTime gameTime)
        {
            switch (solution)
            {
                case 0: modelMaterial.SetEffectParameters(Cell);
                        this.model.Meshes[0].MeshParts[0].Effect = Cell;
                        break;
                case 1: modelMaterial.SetEffectParameters(Simple);
                        this.model.Meshes[0].MeshParts[0].Effect = Simple;
                        break;

                case 2: modelMaterial.SetEffectParameters(Spotlight);
                        this.model.Meshes[0].MeshParts[0].Effect = Spotlight;
                        break;

                case 3: modelMaterial.SetEffectParameters(MultiLight);
                        this.model.Meshes[0].MeshParts[0].Effect = MultiLight;
                        break;

                default: break;
            }

            float timeStep = (float)gameTime.ElapsedGameTime.TotalSeconds * 60.0f;
            
            // Update the window title
            this.Window.Title = "XNA Renderer | FPS: " + this.frameRateCounter.FrameRate;
           //warning flashing lights for status checking only (and or disco parties involving tea)
            ModelMesh mesh = this.model.Meshes[0];
            Effect effect = mesh.Effects[0];

            if (effect.Parameters["lightPosition"] != null)
            effect.Parameters["lightPosition"].SetValue(lightPosition);

            
            if (effect.Parameters["diffuseColors"] != null)
            effect.Parameters["diffuseColors"].SetValue(diffuseColor);
            
            oldState = newState;
            newState = Keyboard.GetState();
             float deltaAngle = 0;

             if (newState.IsKeyDown(Keys.Space) && oldState.IsKeyUp(Keys.Space))
                solution = (solution + 1) % 4;
            if (newState.IsKeyDown(Keys.Left))
                deltaAngle += -0.05f *timeStep;
            if (newState.IsKeyDown(Keys.Right))
                deltaAngle += 0.05f* timeStep;
            if (deltaAngle != 0)
                this.camera.Eye = Vector3.Transform(this.camera.Eye, Matrix.CreateRotationY(deltaAngle));

            base.Update(gameTime);
        }

        protected override void Draw(GameTime gameTime)
        {
            Texture2D texture = CreateTexture(renderTarget);
            //set the backbuffer to black
            GraphicsDevice.Clear(Color.CornflowerBlue);

            if (solution == 1)
            {
                spriteBatch.Begin(SpriteSortMode.Deferred, BlendState.Opaque, SamplerState.LinearClamp, DepthStencilState.Default,
                               RasterizerState.CullNone, Grayscale);
            }

            else
            {
                spriteBatch.Begin(SpriteSortMode.Deferred, BlendState.Opaque, SamplerState.LinearClamp, DepthStencilState.Default,
                               RasterizerState.CullNone);
            }
           
            spriteBatch.Draw(texture, new Rectangle(0, 0, 800, 600), Color.White);


            switch (solution)
            {
                case 0:
                    spriteBatch.DrawString(Font, "Cellshading", Vector2.Zero, Color.White);
                    spriteBatch.DrawString(Font, "Press Left or Right to rotate model", new Vector2(0, 20), Color.White); 
                    spriteBatch.DrawString(Font, "Press Space to change solution", new Vector2(0,40), Color.White); break;
                case 1: 
                    spriteBatch.DrawString(Font, "GrayScale", Vector2.Zero, Color.White); 
                    spriteBatch.DrawString(Font, "Press Left or Right to rotate model", new Vector2(0, 20), Color.White);
                    spriteBatch.DrawString(Font, "Press Space to change solution", new Vector2(0, 40), Color.White); break;
                case 2:
                    spriteBatch.DrawString(Font, "Spolight", Vector2.Zero, Color.White);
                    spriteBatch.DrawString(Font, "Press Left or Right to rotate model", new Vector2(0, 20), Color.White);
                    spriteBatch.DrawString(Font, "Press Space to change solution", new Vector2(0, 40), Color.White); break;

                case 3:
                    spriteBatch.DrawString(Font, "Multiple Lights", Vector2.Zero, Color.White);
                    spriteBatch.DrawString(Font, "Press Left or Right to rotate model", new Vector2(0, 20), Color.White);
                    spriteBatch.DrawString(Font, "Press Space to change solution", new Vector2(0, 40), Color.White); break;

                default: break;
            }


            
            spriteBatch.End();

            base.Draw(gameTime);
        }
    }
}
