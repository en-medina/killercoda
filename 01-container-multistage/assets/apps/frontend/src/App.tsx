import { useState } from 'react'
import UrlShortenerForm from './components/UrlShortenerForm'
import ResultDisplay from './components/ResultDisplay'

interface ShortUrlResult {
  short_url: string
  short_code: string
  original_url: string
}

function App() {
  const [result, setResult] = useState<ShortUrlResult | null>(null)
  const [error, setError] = useState<string>('')

  const handleShorten = async (url: string) => {
    setError('')
    setResult(null)

    try {
      const backendUrl = import.meta.env.VITE_BACKEND_URL || 'http://localhost:5000'

      const response = await fetch(`${backendUrl}/shorten`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ url }),
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || 'Failed to shorten URL')
      }

      setResult(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An unexpected error occurred')
    }
  }

  const handleReset = () => {
    setResult(null)
    setError('')
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      <div className="w-full max-w-2xl">
        <div className="bg-white rounded-2xl shadow-2xl p-8 md:p-12">
          <div className="text-center mb-8">
            <h1 className="text-4xl font-bold text-gray-800 mb-2">
              Link Shortener
            </h1>
            <p className="text-gray-600">
              Transform long URLs into short, shareable links
            </p>
          </div>

          {!result ? (
            <UrlShortenerForm onShorten={handleShorten} error={error} />
          ) : (
            <ResultDisplay result={result} onReset={handleReset} />
          )}

          <div className="mt-8 pt-6 border-t border-gray-200 text-center text-sm text-gray-500">
            <p>Built with React, Flask & Redis</p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default App
