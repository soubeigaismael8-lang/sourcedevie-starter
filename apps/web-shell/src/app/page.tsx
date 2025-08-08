'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { useAuthStore } from '@/store/auth'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { 
  CreditCard, 
  ShoppingCart, 
  MessageSquare, 
  Globe, 
  Bookmark, 
  Briefcase, 
  Calendar,
  ArrowRight,
  Sparkles
} from 'lucide-react'

const features = [
  {
    icon: CreditCard,
    title: 'SVPay',
    description: 'Paiements sécurisés et rapides',
    href: '/svpay',
    color: 'bg-blue-500',
  },
  {
    icon: ShoppingCart,
    title: 'SVStore',
    description: 'Boutique en ligne avec NFTs',
    href: '/svstore',
    color: 'bg-green-500',
  },
  {
    icon: MessageSquare,
    title: 'SVChat',
    description: 'Chat avec reconnaissance vocale',
    href: '/svchat',
    color: 'bg-purple-500',
  },
  {
    icon: Globe,
    title: 'SVBrowser',
    description: 'Navigateur web intégré',
    href: '/svbrowser',
    color: 'bg-orange-500',
  },
  {
    icon: Bookmark,
    title: 'SVLink',
    description: 'Gestionnaire de signets',
    href: '/svlink',
    color: 'bg-pink-500',
  },
  {
    icon: Briefcase,
    title: 'SVCareers',
    description: 'Portail de recrutement',
    href: '/svcareers',
    color: 'bg-indigo-500',
  },
  {
    icon: Calendar,
    title: 'SVServices',
    description: 'Réservation de services',
    href: '/svservices',
    color: 'bg-teal-500',
  },
]

export default function Home() {
  const router = useRouter()
  const { user, isLoading } = useAuthStore()

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="loading"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-background to-muted/20">
      <div className="container mx-auto px-4 py-16">
        <div className="text-center mb-16">
          <Badge variant="secondary" className="mb-4">
            <Sparkles className="w-4 h-4 mr-1" />
            Plateforme Innovante
          </Badge>
          <h1 className="text-4xl md:text-6xl font-bold mb-6 bg-gradient-to-r from-primary to-primary/60 bg-clip-text text-transparent">
            Bienvenue sur SourceDeVie
          </h1>
          <p className="text-xl text-muted-foreground max-w-2xl mx-auto mb-8">
            Votre écosystème numérique complet pour le paiement, le shopping, la communication et bien plus encore.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button 
              size="lg" 
              onClick={() => router.push('/dashboard')}
              className="group"
            >
              Accéder au tableau de bord
              <ArrowRight className="ml-2 h-4 w-4 transition-transform group-hover:translate-x-1" />
            </Button>
            <Button variant="outline" size="lg">
              En savoir plus
            </Button>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {features.map((feature) => {
            const Icon = feature.icon
            return (
              <Card 
                key={feature.title} 
                className="group cursor-pointer transition-all duration-200 hover:shadow-lg hover:-translate-y-1"
                onClick={() => router.push(feature.href)}
              >
                <CardHeader>
                  <div className={`w-12 h-12 rounded-lg ${feature.color} flex items-center justify-center mb-4`}>
                    <Icon className="h-6 w-6 text-white" />
                  </div>
                  <CardTitle className="text-lg">{feature.title}</CardTitle>
                  <CardDescription>{feature.description}</CardDescription>
                </CardHeader>
                <CardContent>
                  <Button variant="ghost" className="w-full group-hover:bg-primary group-hover:text-primary-foreground">
                    Accéder
                    <ArrowRight className="ml-2 h-4 w-4" />
                  </Button>
                </CardContent>
              </Card>
            )
          })}
        </div>

        <div className="mt-20 grid grid-cols-1 md:grid-cols-3 gap-8 text-center">
          <div>
            <div className="text-4xl font-bold text-primary mb-2">10K+</div>
            <div className="text-muted-foreground">Utilisateurs actifs</div>
          </div>
          <div>
            <div className="text-4xl font-bold text-primary mb-2">99.9%</div>
            <div className="text-muted-foreground">Temps de fonctionnement</div>
          </div>
          <div>
            <div className="text-4xl font-bold text-primary mb-2">24/7</div>
            <div className="text-muted-foreground">Support client</div>
          </div>
        </div>
      </div>
    </div>
  )
}
