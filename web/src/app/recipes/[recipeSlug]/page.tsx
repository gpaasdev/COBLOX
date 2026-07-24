import { getRecipes } from "@/lib/roblox";
import { Recipe as SchemaRecipe, WithContext } from "schema-dts";
import Link from "next/link";
import { FlaskConical, Beaker } from "lucide-react";

interface PageProps {
  params: Promise<{
    recipeSlug: string;
  }>;
}

export async function generateStaticParams() {
  const recipes = await getRecipes(10);
  return recipes.map((recipe) => ({
    recipeSlug: recipe.slug,
  }));
}

export async function generateMetadata({ params }: PageProps) {
  const { recipeSlug } = await params;
  const formattedName = recipeSlug.replace(/-/g, " ").toUpperCase();
  return {
    title: `Resep Alkimia: ${formattedName} | COBLOX`,
    description: `Pelajari cara meracik ${formattedName} di COBLOX: Multiverse Alchemy Sanctum beserta bahan-bahan magis yang dibutuhkan.`,
  };
}

export default async function RecipePage({ params }: PageProps) {
  const { recipeSlug } = await params;
  const recipes = await getRecipes(100);
  
  const recipe = recipes.find((r) => r.slug === recipeSlug) || {
    id: "REC-999",
    name: recipeSlug.replace(/-/g, " "),
    description: "Resep misterius yang belum diketahui efeknya.",
    ingredients: ["???", "???"],
    outputType: "Potion",
    slug: recipeSlug,
  };

  const jsonLd: WithContext<SchemaRecipe> = {
    "@context": "https://schema.org",
    "@type": "Recipe",
    name: recipe.name,
    description: recipe.description,
    recipeIngredient: recipe.ingredients,
    recipeInstructions: [
      {
        "@type": "HowToStep",
        text: "Kumpulkan bahan-bahan yang dibutuhkan dari alam atau dengan mengalahkan musuh."
      },
      {
        "@type": "HowToStep",
        text: "Masukkan bahan ke dalam Bejana Aura di Sanctum Anda."
      },
      {
        "@type": "HowToStep",
        text: "Tunggu proses ekstraksi selesai untuk mendapatkan hasilnya."
      }
    ],
    recipeYield: `1 ${recipe.outputType}`,
  };

  return (
    <div className="flex-grow bg-slate-950 p-8">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <div className="max-w-4xl mx-auto">
        <nav className="flex text-sm text-slate-400 mb-8" aria-label="Breadcrumb">
          <ol className="inline-flex items-center space-x-2 md:space-x-3">
            <li><Link href="/" className="hover:text-emerald-400">Beranda</Link></li>
            <li><span className="mx-2">/</span><Link href="/recipes" className="hover:text-emerald-400">Resep</Link></li>
            <li aria-current="page"><span className="mx-2">/</span><span className="text-slate-200">{recipe.name}</span></li>
          </ol>
        </nav>

        <div className="bg-slate-900/40 border border-white/5 rounded-3xl p-8 backdrop-blur-md">
          <div className="flex items-center gap-4 mb-6">
            <div className="w-16 h-16 bg-emerald-500/10 border border-emerald-500/20 rounded-2xl flex items-center justify-center text-emerald-400">
              <FlaskConical className="w-8 h-8" />
            </div>
            <div>
              <h1 className="text-4xl font-extrabold text-white">{recipe.name}</h1>
              <p className="text-slate-400 mt-1">{recipe.description}</p>
            </div>
          </div>
          
          <hr className="my-8 border-white/10" />

          <h2 className="text-xl font-bold text-white mb-4 flex items-center gap-2">
            <Beaker className="w-5 h-5 text-cyan-400" /> Bahan yang Dibutuhkan
          </h2>
          <ul className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {recipe.ingredients.map((ing, i) => (
              <li key={i} className="bg-slate-800/50 border border-white/5 rounded-xl p-4 text-slate-300 font-medium">
                {ing}
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
}
